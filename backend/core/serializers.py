from rest_framework import serializers
from .models import Vendor, MysteryBag, Reservation, NGORequest, Review, NGO, UserLocation
from django.contrib.auth import get_user_model


User = get_user_model()

# 🏪 Vendor
class VendorSerializer(serializers.ModelSerializer):
    logo = serializers.SerializerMethodField()
    image_url = serializers.SerializerMethodField()
    total_reviews = serializers.SerializerMethodField()
    average_rating = serializers.SerializerMethodField()

    class Meta:
        model = Vendor
        fields = [
            'id',
            'name',
            'logo',
            'image_url',
            'total_reviews',
            'average_rating',
            'delivery_time_minutes',
        ]

    def get_logo(self, obj):
        request = self.context.get('request')
        if request and obj.logo:
            return request.build_absolute_uri(obj.logo.url)
        return obj.logo.url if obj.logo else ''



    def get_image_url(self, obj):
        return self.get_logo(obj)

    def get_total_reviews(self, obj):
        return obj.reviews.count()

    def get_average_rating(self, obj):
        reviews = obj.reviews.all()
        if reviews.exists():
            return round(sum(r.rating for r in reviews) / reviews.count(), 1)
        return 0.0





# 🎁 Mystery Bag
class MysteryBagSerializer(serializers.ModelSerializer):
    vendor = VendorSerializer(read_only=True)

    class Meta:
        model = MysteryBag
        exclude = ['hidden_contents']

# 🎁 Mystery Bag with Contents (for Reservations)
class MysteryBagWithContentsSerializer(serializers.ModelSerializer):
    vendor = VendorSerializer(read_only=True)

    class Meta:
        model = MysteryBag
        fields = '__all__'

# 🛒 Reservation
class ReservationSerializer(serializers.ModelSerializer):
    bag_title = serializers.CharField(source='bag.title', read_only=True)
    vendor_name = serializers.CharField(source='bag.vendor.name', read_only=True)
    bag_contents = serializers.CharField(source='bag.hidden_contents', read_only=True)
    type = serializers.CharField(default='ngo')  # 👈 Added

    class Meta:
        model = Reservation
        fields = [
            'id',
            'reserved_at',
            'price_paid',
            'payment_method',
            'delivery_address',
            'phone_number',
            'notes',
            'is_collected',
            'bag_title',
            'vendor_name',
            'bag_contents',
            'type',
        ]

# 🧾 Simplified Bag View for NGO Donation Listing
class SimpleMysteryBagSerializer(serializers.ModelSerializer):
    vendor_name = serializers.CharField(source='vendor.name', read_only=True)

    class Meta:
        model = MysteryBag
        fields = [
            'id',
            'title',
            'description',
            'quantity_available',
            'pickup_start',
            'pickup_end',
            'vendor_name',
            'is_donation'
        ]

# 📊 Dashboard summary
class NGODashboardSummarySerializer(serializers.Serializer):
    total_donations = serializers.IntegerField()
    total_items_rescued = serializers.IntegerField()

# 🆘 NGO Request
class NGORequestSerializer(serializers.ModelSerializer):
    ngo = serializers.StringRelatedField(read_only=True)

    class Meta:
        model = NGORequest
        fields = '__all__'

# ⭐ Reviews
class ReviewSerializer(serializers.ModelSerializer):
    user_name = serializers.SerializerMethodField()

    class Meta:
        model = Review
        fields = ['id', 'user_name', 'rating', 'comment', 'created_at']  # Add other fields if needed

    def get_user_name(self, obj):
        user = obj.user
        return user.get_full_name() or user.username or "Customer"


class NGOProfileSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(source='user.email', read_only=True)
    phone_number = serializers.CharField(source='user.phone_number', read_only=True)  # ✅ NEW

    class Meta:
        model = NGO
        fields = [
            'organization_name',
            'region',
            'description',
            'phone_number',   # ✅ Now pulled from user
            'email',
            'website',
            'logo',
        ]



class UserLocationSerializer(serializers.ModelSerializer):
    user = serializers.PrimaryKeyRelatedField(read_only=True)  # Explicit read-only
    
    class Meta:
        model = UserLocation
        fields = '__all__'
        read_only_fields = ['user', 'created_at', 'id']

    def create(self, validated_data):
        # Get user from context more safely
        user = self.context.get('request').user if self.context.get('request') else None
        
        if not user:
            raise serializers.ValidationError(
                {"user": "Authentication credentials were not provided."},
                code='authentication_failed'
            )
            
        validated_data.pop('user', None)  # Remove if present
        return UserLocation.objects.create(user=user, **validated_data)



from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

class MyTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token['role'] = getattr(user, 'role', '')
        token['is_staff'] = user.is_staff
        token['phone_number'] = user.phone_number  # ✅ NEW
        return token

    def validate(self, attrs):
        data = super().validate(attrs)
        data['email'] = self.user.email
        data['role'] = getattr(self.user, 'role', '')
        data['is_staff'] = self.user.is_staff
        data['phone_number'] = self.user.phone_number  # ✅ NEW
        return data


class UserProfileSerializer(serializers.ModelSerializer):
    full_name = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ['full_name', 'phone_number', 'email']
        read_only_fields = ['email']

    def get_full_name(self, obj):
        return f"{obj.first_name} {obj.last_name}".strip()
