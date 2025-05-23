from django.db import models
from django.contrib.auth.models import AbstractUser
from django.conf import settings
from django.utils import timezone
from django.core.validators import MinValueValidator, MaxValueValidator
from cloudinary.models import CloudinaryField
from django.contrib.auth import get_user_model

# 🌟 Custom user with role + phone number
class CustomUser(AbstractUser):
    ROLE_CHOICES = (
        ('user', 'User'),
        ('vendor', 'Vendor'),
        ('ngo', 'NGO'),
    )
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='user')
    phone_number = models.CharField(max_length=20, blank=True, null=True)  # ✅ Added

    def __str__(self):
        return self.username


# 🏪 Vendor Profile
class Vendor(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    address = models.CharField(max_length=255, default="Default Address")
    latitude = models.FloatField(default=33.8886)
    longitude = models.FloatField(default=35.4955)
    delivery_available = models.BooleanField(default=False)
    delivery_time_minutes = models.PositiveIntegerField(default=30)
    average_rating = models.FloatField(default=0.0)
    logo = CloudinaryField('logo', blank=True, null=True)

    def __str__(self):
        return self.name


# 🎁 Mystery Bag Listing
class MysteryBag(models.Model):
    vendor = models.ForeignKey(Vendor, on_delete=models.CASCADE, related_name='mystery_bags')
    title = models.CharField(max_length=100)
    description = models.TextField()
    quantity_available = models.PositiveIntegerField(default=1)
    price = models.DecimalField(max_digits=6, decimal_places=2)
    is_donation = models.BooleanField(default=False)
    hidden_contents = models.TextField(blank=True, null=True)
    pickup_start = models.TimeField()
    pickup_end = models.TimeField()
    date_posted = models.DateTimeField(default=timezone.now)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.title} from {self.vendor.name}"


# 📦 Reservation
class Reservation(models.Model):
    PAYMENT_CHOICES = (
        ('cash', 'Cash on Delivery'),
        ('card', 'Credit Card'),
    )

    RESERVATION_TYPE = (
        ('user', 'User'),
        ('ngo', 'NGO'),
    )

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    bag = models.ForeignKey(MysteryBag, on_delete=models.CASCADE)
    reserved_at = models.DateTimeField(auto_now_add=True)
    is_collected = models.BooleanField(default=False)
    price_paid = models.DecimalField(max_digits=6, decimal_places=2, default=0.0)

    delivery_address = models.TextField(blank=True, null=True)
    phone_number = models.CharField(max_length=20, blank=True, null=True)
    payment_method = models.CharField(max_length=20, choices=PAYMENT_CHOICES, default='cash')
    notes = models.TextField(blank=True, null=True)

    type = models.CharField(max_length=10, choices=RESERVATION_TYPE, default='user')

    def __str__(self):
        return f"{self.user.username} reserved {self.bag.title} as {self.type}"


# 👐 NGO Requests
class NGORequest(models.Model):
    ngo = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    title = models.CharField(max_length=100)
    description = models.TextField()
    num_people = models.PositiveIntegerField()
    needed_by = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True)
    is_fulfilled = models.BooleanField(default=False)

    def __str__(self):
        return f"Request from {self.ngo.username}"


# ⭐ Vendor Reviews
class Review(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    vendor = models.ForeignKey('Vendor', on_delete=models.CASCADE, related_name='reviews')
    rating = models.IntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)])
    comment = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - {self.vendor.name} ({self.rating})"


# 🏢 NGO Profile (phone_number removed ✅)
class NGO(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    organization_name = models.CharField(max_length=255)
    region = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    website = models.URLField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    logo = CloudinaryField('logo', blank=True, null=True)

    def __str__(self):
        return self.organization_name


# 📍 Saved Locations
class UserLocation(models.Model):
    user = models.ForeignKey(get_user_model(), on_delete=models.CASCADE, related_name='locations')
    name = models.CharField(max_length=100, blank=True)
    latitude = models.FloatField()
    longitude = models.FloatField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - {self.name or 'Unnamed'}"
