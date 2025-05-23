from django.contrib.auth import get_user_model
from django.db.models import Sum
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.decorators import parser_classes
from rest_framework.permissions import AllowAny
from django.contrib.auth.hashers import make_password
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated, IsAdminUser
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.utils import timezone
from django.db.models import Avg, Count  
from datetime import timedelta
from django.views.decorators.csrf import csrf_exempt



from .models import Vendor, MysteryBag, Reservation, NGORequest, Review, NGO, UserLocation, CustomUser

from .serializers import (
    VendorSerializer,
    MysteryBagSerializer,
    MysteryBagWithContentsSerializer,
    ReservationSerializer,
    SimpleMysteryBagSerializer,
    NGODashboardSummarySerializer,
    NGORequestSerializer,
    ReviewSerializer,
    NGOProfileSerializer,
    UserLocationSerializer,
    MyTokenObtainPairSerializer,
    UserProfileSerializer
)

User = get_user_model()

# ✅ Get all vendors
@api_view(['GET'])
def get_vendors(request):
    vendors = Vendor.objects.all()
    serializer = VendorSerializer(vendors, many=True, context={'request': request})
    return Response(serializer.data)


# ✅ Get all active mystery bags
@api_view(['GET'])
def get_all_mystery_bags(request):
    bags = MysteryBag.objects.filter(is_active=True)
    serializer = MysteryBagSerializer(bags, many=True)
    return Response(serializer.data)

# ✅ Get mystery bags by vendor
@api_view(['GET'])
def get_mystery_bags_by_vendor(request, vendor_id):
    try:
        vendor = Vendor.objects.get(id=vendor_id)
        bags = MysteryBag.objects.filter(vendor=vendor, is_active=True)
        serializer = MysteryBagSerializer(bags, many=True, context={'request': request})
        return Response(serializer.data)
    except Vendor.DoesNotExist:
        return Response({'detail': 'Vendor not found.'}, status=status.HTTP_404_NOT_FOUND)


# ✅ Vendor: Get own mystery bags
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_vendor_my_bags(request):
    try:
        if request.user.role != 'vendor':
            return Response({'detail': 'Not authorized.'}, status=status.HTTP_403_FORBIDDEN)

        vendor = Vendor.objects.get(name=request.user.first_name)
        bags = MysteryBag.objects.filter(vendor=vendor)
        serializer = MysteryBagSerializer(bags, many=True, context={'request': request})
        return Response(serializer.data)

    except Vendor.DoesNotExist:
        return Response({'detail': 'Vendor profile not found.'}, status=status.HTTP_404_NOT_FOUND)


@csrf_exempt
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def reserve_bag(request, bag_id):
    print("✅ Reached reserve_bag view with bag_id:", bag_id)
    try:
        bag = MysteryBag.objects.get(id=bag_id, is_active=True)

        if bag.quantity_available <= 0:
            return Response({'detail': 'Bag is no longer available.'}, status=status.HTTP_400_BAD_REQUEST)

        delivery_address = request.data.get('delivery_address', '')
        phone_number = request.data.get('phone_number', '')
        payment_method = request.data.get('payment_method', 'cash')
        notes = request.data.get('notes', '')

        # ✅ Create reservation
        Reservation.objects.create(
            user=request.user,
            bag=bag,
            price_paid=0.0 if bag.is_donation else bag.price,
            delivery_address=delivery_address,
            phone_number=phone_number,
            payment_method=payment_method,
            notes=notes
        )

        # ✅ Update bag quantity
        bag.quantity_available -= 1
        if bag.quantity_available == 0:
            bag.is_active = False
        bag.save()

        # ✅ Prepare hidden items
        items = [item.strip() for item in bag.hidden_contents.split(',')] if bag.hidden_contents else []

        return Response({
            'detail': 'Reservation successful!',
            'items': items
        }, status=201)

    except MysteryBag.DoesNotExist:
        return Response({'detail': 'Bag not found.'}, status=404)



# ✅ Vendor: Update Mystery Bag
@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def update_mystery_bag(request, bag_id):
    try:
        bag = MysteryBag.objects.get(id=bag_id)
        vendor = Vendor.objects.get(name=request.user.first_name)

        if bag.vendor != vendor:
            return Response({'detail': 'You do not have permission to edit this bag.'}, status=status.HTTP_403_FORBIDDEN)

        data = request.data
        bag.title = data.get('title', bag.title)
        bag.description = data.get('description', bag.description)
        bag.hidden_contents = data.get('hidden_contents', bag.hidden_contents)
        bag.price = data.get('price', bag.price)
        bag.quantity_available = data.get('quantity_available', bag.quantity_available)
        bag.pickup_start = data.get('pickup_start', bag.pickup_start)
        bag.pickup_end = data.get('pickup_end', bag.pickup_end)
        bag.is_donation = data.get('is_donation', bag.is_donation)
        bag.save()

        serializer = MysteryBagSerializer(bag)
        return Response(serializer.data)

    except MysteryBag.DoesNotExist:
        return Response({'detail': 'Mystery bag not found.'}, status=status.HTTP_404_NOT_FOUND)

# ✅ Vendor: Delete Mystery Bag
@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_mystery_bag(request, bag_id):
    try:
        bag = MysteryBag.objects.get(id=bag_id)
        vendor = Vendor.objects.get(name=request.user.first_name)

        if bag.vendor != vendor:
            return Response({'detail': 'You do not have permission to delete this bag.'}, status=status.HTTP_403_FORBIDDEN)

        bag.delete()
        return Response({'detail': 'Mystery bag deleted successfully.'}, status=status.HTTP_204_NO_CONTENT)

    except MysteryBag.DoesNotExist:
        return Response({'detail': 'Mystery bag not found.'}, status=status.HTTP_404_NOT_FOUND)

# ✅ Vendor: Mark Reservation as Collected
@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def mark_reservation_collected(request, reservation_id):
    try:
        reservation = Reservation.objects.get(id=reservation_id)
        vendor = Vendor.objects.get(name=request.user.first_name)

        if reservation.bag.vendor != vendor:
            return Response({'detail': 'You do not have permission to update this reservation.'}, status=status.HTTP_403_FORBIDDEN)

        reservation.is_collected = True
        reservation.save()

        return Response({'detail': 'Reservation marked as collected.'})

    except Reservation.DoesNotExist:
        return Response({'detail': 'Reservation not found.'}, status=status.HTTP_404_NOT_FOUND)

# ✅ Get current user's reservations
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_my_reservations(request):
    reservations = Reservation.objects.filter(user=request.user).order_by('-reserved_at')

    data = []
    for r in reservations:
        data.append({
            'bag_id': r.bag.id,
            'title': r.bag.title,
            'description': r.bag.description,
            'vendor': r.bag.vendor.name,
            'reserved_at': r.reserved_at,
            'price_paid': str(r.price_paid),
            'payment_method': r.payment_method,
            'delivery_address': r.delivery_address,
            'phone_number': r.phone_number,
            'notes': r.notes,
            'is_collected': r.is_collected,
            'contents_revealed': r.bag.hidden_contents,
        })

    return Response(data, status=200)


# ✅ Get logged-in user profile
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_user_profile(request):
    user = request.user
    return Response({
        "full_name": user.get_full_name(),
        "email": user.email,
        "phone_number": user.phone_number,  # Changed from 'phone' to 'phone_number'
        "role": getattr(user, 'role', 'user'),
        "date_joined": user.date_joined.strftime('%Y-%m-%d'),
    })

# Update User information
@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def update_user_profile(request):
    user = request.user
    data = request.data

    # Split and assign full name
    if 'full_name' in data:
        name_parts = data['full_name'].strip().split(" ", 1)
        user.first_name = name_parts[0]
        user.last_name = name_parts[1] if len(name_parts) > 1 else ''

    # Directly update phone number if provided
    if 'phone_number' in data:
        user.phone_number = data['phone_number']

    # Save changes using serializer
    serializer = UserProfileSerializer(user, data=data, partial=True)
    if serializer.is_valid():
        user.save()
        return Response({
            "full_name": f"{user.first_name} {user.last_name}".strip(),
            "email": user.email,
            "phone_number": user.phone_number,
            "role": getattr(user, 'role', 'user'),
        }, status=200)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ✅ Vendor: Get own reservations
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_vendor_reservations(request):
    try:
        if request.user.role != 'vendor':
            return Response({'detail': 'Not authorized.'}, status=status.HTTP_403_FORBIDDEN)

        vendor = Vendor.objects.get(name=request.user.first_name)
        reservations = Reservation.objects.filter(bag__vendor=vendor).order_by('-reserved_at')

        data = []
        for r in reservations:
            data.append({
                'reservation_id': r.id,
                'bag_title': r.bag.title,
                'user_name': r.user.first_name or r.user.username,
                'reserved_at': r.reserved_at,
                'is_collected': r.is_collected,
            })

        return Response(data)

    except Vendor.DoesNotExist:
        return Response({'detail': 'Vendor profile not found.'}, status=status.HTTP_404_NOT_FOUND)

# ✅ Vendor: Update Profile + Logo Upload
@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
@parser_classes([MultiPartParser, FormParser])
def update_vendor_profile(request):
    if request.user.role != 'vendor':
        return Response({'detail': 'Not authorized.'}, status=403)

    try:
        vendor = Vendor.objects.get(name=request.user.first_name)
        data = request.data

        vendor.description = data.get('description', vendor.description)
        vendor.address = data.get('address', vendor.address)
        vendor.latitude = data.get('latitude', vendor.latitude)
        vendor.longitude = data.get('longitude', vendor.longitude)
        vendor.delivery_available = data.get('delivery_available', vendor.delivery_available)
        vendor.delivery_time_minutes = data.get('delivery_time_minutes', vendor.delivery_time_minutes)

        if 'logo' in request.FILES:
            vendor.logo = request.FILES['logo']

        vendor.save()
        return Response(VendorSerializer(vendor).data)

    except Vendor.DoesNotExist:
        return Response({'detail': 'Vendor not found.'}, status=404)

# ✅ User registration
@api_view(['POST'])
def register_user(request):
    try:
        data = request.data

        full_name = data.get('full_name', '').strip()
        email = data.get('email', '').strip()
        phone = data.get('phone', '').strip()
        password = data.get('password', '')
        confirm_password = data.get('confirm_password', '')

        if not all([full_name, email, phone, password, confirm_password]):
            return Response({"detail": "All fields are required."}, status=status.HTTP_400_BAD_REQUEST)

        if password != confirm_password:
            return Response({"detail": "Passwords do not match."}, status=status.HTTP_400_BAD_REQUEST)

        if User.objects.filter(email=email).exists():
            return Response({"detail": "Email already registered."}, status=status.HTTP_400_BAD_REQUEST)

        user = User.objects.create(
            username=email.split('@')[0],
            email=email,
            password=make_password(password),
            first_name=full_name,
        )

        user.phone_number = phone  # ✅ Save phone number here
        user.save()

        refresh = RefreshToken.for_user(user)
        return Response({
            'refresh': str(refresh),
            'access': str(refresh.access_token),
            'role': user.role,
        }, status=status.HTTP_201_CREATED)

    except Exception as e:
        return Response({"detail": f"Unexpected error: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ✅ JWT Token Pair customization
class MyTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token['role'] = getattr(user, 'role', '')
        token['is_staff'] = user.is_staff  # ✅ this must be aligned correctly
        return token

    def validate(self, attrs):
        data = super().validate(attrs)
        data['email'] = self.user.email
        data['role'] = getattr(self.user, 'role', '')
        data['is_staff'] = self.user.is_staff
        return data

class MyTokenObtainPairView(TokenObtainPairView):
    serializer_class = MyTokenObtainPairSerializer



@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_mystery_bag(request):
    try:
        if request.user.role != 'vendor':
            return Response({'detail': 'Not authorized.'}, status=status.HTTP_403_FORBIDDEN)

        vendor = Vendor.objects.get(name=request.user.first_name)

        data = request.data
        bag = MysteryBag.objects.create(
            vendor=vendor,
            title=data.get('title'),
            description=data.get('description'),
            hidden_contents=data.get('hidden_contents'),
            price=data.get('price'),
            quantity_available=data.get('quantity_available'),
            pickup_start=data.get('pickup_start'),
            pickup_end=data.get('pickup_end'),
            is_donation=data.get('is_donation', False),
        )

        serializer = MysteryBagSerializer(bag)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    except Vendor.DoesNotExist:
        return Response({'detail': 'Vendor profile not found.'}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({'detail': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_vendor_profile(request):
    try:
        if request.user.role != 'vendor':
            return Response({'detail': 'Not authorized.'}, status=status.HTTP_403_FORBIDDEN)

        vendor = Vendor.objects.get(name=request.user.first_name)

        return Response({
            'name': vendor.name,
            'description': vendor.description,
            'address': vendor.address,
            'latitude': vendor.latitude,
            'longitude': vendor.longitude,
            'delivery_available': vendor.delivery_available,
            'delivery_time_minutes': vendor.delivery_time_minutes,
        }, status=200)

    except Vendor.DoesNotExist:
        return Response({'detail': 'Vendor profile not found.'}, status=status.HTTP_404_NOT_FOUND)


# ✅ Vendor Dashboard Summary
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_vendor_dashboard_summary(request):
    try:
        if request.user.role != 'vendor':
            return Response({'detail': 'Not authorized.'}, status=status.HTTP_403_FORBIDDEN)

        vendor = Vendor.objects.get(name=request.user.first_name)

        total_bags = MysteryBag.objects.filter(vendor=vendor).count()
        total_reservations = Reservation.objects.filter(bag__vendor=vendor).count()
        collected_reservations = Reservation.objects.filter(bag__vendor=vendor, is_collected=True).count()

        if total_reservations > 0:
            collected_percentage = round((collected_reservations / total_reservations) * 100, 1)
        else:
            collected_percentage = 0.0

        return Response({
            "total_bags": total_bags,
            "total_reservations": total_reservations,
            "collected_reservations": collected_reservations,
            "collected_percentage": collected_percentage,
        })

    except Vendor.DoesNotExist:
        return Response({'detail': 'Vendor profile not found.'}, status=status.HTTP_404_NOT_FOUND)


# ⭐ Submit a review for a vendor
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_review(request, vendor_id):
    data = request.data
    rating = data.get('rating')
    comment = data.get('comment', '')

    if not rating:
        return Response({"detail": "Rating is required."}, status=400)

    if not (1 <= int(rating) <= 5):
        return Response({"detail": "Rating must be between 1 and 5."}, status=400)

    try:
        vendor = Vendor.objects.get(id=vendor_id)

        Review.objects.create(
            user=request.user,
            vendor=vendor,
            rating=rating,
            comment=comment,
        )
        return Response({"detail": "Review submitted successfully."}, status=201)

    except Vendor.DoesNotExist:
        return Response({"detail": "Vendor not found."}, status=404)

# ⭐ Get reviews for a vendor
@api_view(['GET'])
def get_reviews_by_vendor(request, vendor_id):
    try:
        vendor = Vendor.objects.get(id=vendor_id)
        reviews = vendor.reviews.all().order_by('-created_at')
        serializer = ReviewSerializer(reviews, many=True)
        return Response(serializer.data)

    except Vendor.DoesNotExist:
        return Response({'detail': 'Vendor not found.'}, status=404)


# ✅ Vendor: Get own received reviews
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_vendor_reviews(request):
    try:
        if request.user.role != 'vendor':
            return Response({'detail': 'Not authorized.'}, status=status.HTTP_403_FORBIDDEN)

        vendor = Vendor.objects.get(name=request.user.first_name)
        reviews = vendor.reviews.all().order_by('-created_at')  # vendor.reviews from related_name in model

        data = []
        for review in reviews:
            data.append({
                'user_name': review.user.get_full_name() or review.user.username,
                'user_phone': getattr(review.user, 'phone', ''),
                'rating': review.rating,
                'comment': review.comment,
                'created_at': review.created_at.strftime('%Y-%m-%d %H:%M'),
            })

        return Response(data, status=200)

    except Vendor.DoesNotExist:
        return Response({'detail': 'Vendor profile not found.'}, status=status.HTTP_404_NOT_FOUND)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_ngo_dashboard_summary(request):
    if request.user.role != 'ngo':
        return Response({'detail': 'Not authorized.'}, status=status.HTTP_403_FORBIDDEN)

    total_reservations = Reservation.objects.filter(user=request.user, type='ngo').count()
    total_items = Reservation.objects.filter(user=request.user, type='ngo').aggregate(
        total=Sum('bag__quantity_available')
    )['total'] or 0

    data = {
        "total_donations": total_reservations,
        "total_items_rescued": total_items,
    }
    serializer = NGODashboardSummarySerializer(data)
    return Response(serializer.data)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_donation_bags(request):
    if request.user.role != 'ngo':
        return Response({'detail': 'Not authorized.'}, status=status.HTTP_403_FORBIDDEN)

    bags = MysteryBag.objects.filter(is_donation=True, is_active=True, quantity_available__gt=0)
    serializer = SimpleMysteryBagSerializer(bags, many=True)
    return Response(serializer.data)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def reserve_donation_bag(request, bag_id):
    if request.user.role != 'ngo':
        return Response({'detail': 'Not authorized.'}, status=status.HTTP_403_FORBIDDEN)

    try:
        bag = MysteryBag.objects.get(id=bag_id, is_active=True, is_donation=True)
        if bag.quantity_available <= 0:
            return Response({'detail': 'Bag is no longer available.'}, status=status.HTTP_400_BAD_REQUEST)

        Reservation.objects.create(
            user=request.user,
            bag=bag,
            price_paid=0.0,
            type='ngo',
            delivery_address=request.data.get('delivery_address', ''),
            phone_number=request.data.get('phone_number', ''),
            payment_method='cash',
            notes=request.data.get('notes', '')
        )

        bag.quantity_available -= 1
        if bag.quantity_available == 0:
            bag.is_active = False
        bag.save()

        return Response({'detail': 'Donation reserved successfully!'}, status=status.HTTP_201_CREATED)

    except MysteryBag.DoesNotExist:
        return Response({'detail': 'Donation bag not found.'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_ngo_profile(request):
    try:
        ngo = NGO.objects.get(user=request.user)
        serializer = NGOProfileSerializer(ngo)
        return Response(serializer.data)
    except NGO.DoesNotExist:
        return Response({'detail': 'NGO profile not found.'}, status=status.HTTP_404_NOT_FOUND)



# ✅ NGO: Update Profile + Logo Upload
@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def update_ngo_profile(request):
    try:
        ngo = NGO.objects.get(user=request.user)
        serializer = NGOProfileSerializer(ngo, data=request.data, partial=True)  # partial=True allows for partial updates
        if serializer.is_valid():
            serializer.save()

            # ✅ Update User's phone number
            phone = request.data.get('phone_number')
            if phone:
                request.user.phone_number = phone
                request.user.save()

            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    except NGO.DoesNotExist:
        return Response({'detail': 'NGO profile not found.'}, status=status.HTTP_404_NOT_FOUND)



@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_ngo_profile(request):
    if request.user.role != 'ngo':
        return Response({'detail': 'Not authorized.'}, status=status.HTTP_403_FORBIDDEN)

    if NGO.objects.filter(user=request.user).exists():
        return Response({'detail': 'NGO profile already exists.'}, status=400)

    serializer = NGOProfileSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(user=request.user)
        return Response({'detail': 'NGO profile created successfully.'}, status=201)
    return Response(serializer.errors, status=400)



@api_view(['GET'])
@permission_classes([AllowAny])  # 🔓 Make it public
def public_ngos(request):
    ngos = NGO.objects.all()
    serializer = NGOProfileSerializer(ngos, many=True)
    return Response(serializer.data)



@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_admin_dashboard_stats(request):
    if not request.user.is_staff:  # Or use is_superuser if needed
        return Response({'detail': 'Not authorized'}, status=403)

    total_users = User.objects.count()
    total_vendors = Vendor.objects.count()
    total_ngos = NGO.objects.count()
    total_bags = MysteryBag.objects.count()
    donated_bags = MysteryBag.objects.filter(is_donation=True).count()
    total_reservations = Reservation.objects.count()

    return Response({
        'total_users': total_users,
        'total_vendors': total_vendors,
        'total_ngos': total_ngos,
        'total_bags': total_bags,
        'donated_bags': donated_bags,
        'total_reservations': total_reservations,
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_user_locations(request):
    locations = UserLocation.objects.filter(user=request.user)
    serializer = UserLocationSerializer(locations, many=True)
    return Response(serializer.data)



# In your view (likely views.py)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_user_location(request):
    serializer = UserLocationSerializer(
        data=request.data,
        context={'request': request}  # THIS IS CRUCIAL
    )
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=201)
    return Response(serializer.errors, status=400)


    # ✅ List all users
@api_view(['GET'])
@permission_classes([IsAdminUser])
def list_users(request):
    users = User.objects.all().values('id', 'first_name', 'email', 'role', 'is_active', 'date_joined')
    return Response(list(users))

# ✅ Toggle user active status
@api_view(['PATCH'])
@permission_classes([IsAdminUser])
def toggle_user_active(request, user_id):
    try:
        user = User.objects.get(id=user_id)
        user.is_active = not user.is_active
        user.save()
        return Response({'detail': f"User active status set to {user.is_active}"})
    except User.DoesNotExist:
        return Response({'detail': 'User not found'}, status=404)

# ✅ Delete user
@api_view(['DELETE'])
@permission_classes([IsAdminUser])
def delete_user(request, user_id):
    try:
        User.objects.get(id=user_id).delete()
        return Response({'detail': 'User deleted'})
    except User.DoesNotExist:
        return Response({'detail': 'User not found'}, status=404)


# ✅ List all reviews
@api_view(['GET'])
@permission_classes([IsAdminUser])
def list_reviews(request):
    reviews = Review.objects.all().order_by('-created_at')
    serializer = ReviewSerializer(reviews, many=True)
    return Response(serializer.data)

# ✅ Delete review
@api_view(['DELETE'])
@permission_classes([IsAdminUser])
def delete_review(request, review_id):
    try:
        Review.objects.get(id=review_id).delete()
        return Response({'detail': 'Review deleted'})
    except Review.DoesNotExist:
        return Response({'detail': 'Review not found'}, status=404)

# ✅ List all bags
@api_view(['GET'])
@permission_classes([IsAdminUser])
def list_bags(request):
    bags = MysteryBag.objects.all()
    serializer = MysteryBagSerializer(bags, many=True)
    return Response(serializer.data)

# ✅ Delete bag
@api_view(['DELETE'])
@permission_classes([IsAdminUser])
def delete_bag(request, bag_id):
    try:
        MysteryBag.objects.get(id=bag_id).delete()
        return Response({'detail': 'Bag deleted'})
    except MysteryBag.DoesNotExist:
        return Response({'detail': 'Bag not found'}, status=404)

# ✅ Toggle bag active status
@api_view(['PATCH'])
@permission_classes([IsAdminUser])
def toggle_bag_active(request, bag_id):
    try:
        bag = MysteryBag.objects.get(id=bag_id)
        bag.is_active = not bag.is_active
        bag.save()
        return Response({'detail': f"Bag active status set to {bag.is_active}"})
    except MysteryBag.DoesNotExist:
        return Response({'detail': 'Bag not found'}, status=404)

# ✅ List all reservations
@api_view(['GET'])
@permission_classes([IsAdminUser])
def list_reservations(request):
    reservations = Reservation.objects.all().order_by('-reserved_at')
    serializer = ReservationSerializer(reservations, many=True)
    return Response(serializer.data)

# ✅ Delete reservation
@api_view(['DELETE'])
@permission_classes([IsAdminUser])
def delete_reservation(request, reservation_id):
    try:
        Reservation.objects.get(id=reservation_id).delete()
        return Response({'detail': 'Reservation deleted'})
    except Reservation.DoesNotExist:
        return Response({'detail': 'Reservation not found'}, status=404)



@api_view(['GET'])
def get_vendor_private_bags(request):
    return Response({'detail': 'Placeholder response'})

@api_view(['PATCH'])
def update_private_mystery_bag(request, bag_id):
    return Response({'detail': f'Updated bag {bag_id}'})

@api_view(['GET'])
def admin_get_all_bags(request):
    return Response({'detail': 'All bags for admin'})

@api_view(['GET'])
def admin_get_bag_details(request, bag_id):
    return Response({'detail': f'Details of bag {bag_id}'})


@api_view(['POST'])
@permission_classes([AllowAny])
def create_vendor_profile(request):
    try:
        data = request.data
        user_id = data.get('user_id')
        name = data.get('name', '')
        user = User.objects.get(id=user_id)

        vendor = Vendor.objects.create(user=user, name=name)
        return Response({"detail": "Vendor profile created", "vendor_id": vendor.id}, status=201)
    except Exception as e:
        return Response({"detail": str(e)}, status=400)


@api_view(['GET'])
@permission_classes([IsAdminUser])
def vendor_analytics(request):
    vendors = Vendor.objects.all()
    result = []
    for vendor in vendors:
        reservations = Reservation.objects.filter(bag__vendor=vendor).count()
        result.append({
            "name": vendor.name,
            "reservations": reservations
        })
    return Response(result)


@api_view(['GET'])
@permission_classes([IsAdminUser])
def review_analytics(request):
    ratings = Review.objects.values('vendor__name')\
        .annotate(avg_rating=Avg('rating'))

    counts = Review.objects.values('vendor__name')\
        .annotate(review_count=Count('id'))

    avg_ratings = {entry['vendor__name']: round(entry['avg_rating'], 2) for entry in ratings}
    review_counts = {entry['vendor__name']: entry['review_count'] for entry in counts}

    return Response({
        "avg_ratings": avg_ratings,
        "review_counts": review_counts
    })


@api_view(['GET'])
@permission_classes([IsAdminUser])
def reservation_analytics(request):
    today = timezone.now().date()
    start_date = today - timedelta(days=30)

    reservations = Reservation.objects.filter(reserved_at__date__gte=start_date)
    daily_counts = {}
    for r in reservations:
        day = r.reserved_at.date().isoformat()
        daily_counts[day] = daily_counts.get(day, 0) + 1

    paid_count = Reservation.objects.exclude(payment_method='cash').count()
    unpaid_count = Reservation.objects.filter(payment_method='cash').count()

    collected = Reservation.objects.filter(is_collected=True).count()
    not_collected = Reservation.objects.filter(is_collected=False).count()

    return Response({
        "daily_counts": daily_counts,
        "paid": paid_count,
        "unpaid": unpaid_count,
        "status_counts": {
            "collected": collected,
            "not_collected": not_collected
        }
    })


@api_view(['GET'])
@permission_classes([IsAdminUser])
def bag_analytics(request):
    active_count = MysteryBag.objects.filter(is_active=True).count()
    expired_count = MysteryBag.objects.filter(is_active=False).count()

    bags_per_vendor = MysteryBag.objects.values('vendor__name')\
        .annotate(count=Count('id'))
    bags_dict = {entry['vendor__name']: entry['count'] for entry in bags_per_vendor}

    return Response({
        "active": active_count,
        "expired": expired_count,
        "bags_per_vendor": bags_dict
    })


@api_view(['GET'])
@permission_classes([IsAdminUser])
def user_analytics(request):
    roles = User.objects.values('role').annotate(count=Count('id'))
    role_counts = {entry['role'] or 'unknown': entry['count'] for entry in roles}

    ngo_regions = {}
    if hasattr(User, 'region'):
        ngos = User.objects.filter(role='ngo').values('region').annotate(count=Count('id'))
        ngo_regions = {entry['region'] or 'unspecified': entry['count'] for entry in ngos}

    start_date = timezone.now().date() - timedelta(days=30)
    new_users = User.objects.filter(date_joined__date__gte=start_date)

    daily_new = {}
    for u in new_users:
        day = u.date_joined.date().isoformat()
        daily_new[day] = daily_new.get(day, 0) + 1

    return Response({
        "role_counts": role_counts,
        "ngo_regions": ngo_regions,
        "new_users": daily_new
    })
