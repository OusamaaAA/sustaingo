from django.contrib import admin 
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, Vendor, MysteryBag, Reservation, NGORequest, Review, NGO, UserLocation

# 🔐 Extended Custom User Admin
class CustomUserAdmin(UserAdmin):
    model = CustomUser
    list_display = ('username', 'email', 'first_name', 'last_name', 'role', 'phone_number', 'is_staff', 'is_superuser')
    fieldsets = UserAdmin.fieldsets + (
        ("Role Info", {'fields': ('role', 'phone_number')}),
    )
    add_fieldsets = UserAdmin.add_fieldsets + (
        ("Role Info", {'fields': ('role', 'phone_number')}),
    )

# 🏪 Vendor Admin
@admin.register(Vendor)
class VendorAdmin(admin.ModelAdmin):
    list_display = ('name', 'address', 'delivery_available', 'average_rating', 'logo')
    search_fields = ('name', 'address')
    list_filter = ('delivery_available',)


# 🧑‍🤝‍🧑 NGO Admin
@admin.register(NGO)
class NGOAdmin(admin.ModelAdmin):
    list_display = ('organization_name', 'user', 'region', 'get_phone', 'description', 'created_at')
    search_fields = ('organization_name', 'user__username', 'region')
    list_filter = ('region', 'created_at')

    def get_phone(self, obj):
        return obj.user.phone_number
    get_phone.short_description = 'Phone Number'


# 🎁 Mystery Bag Admin with hidden_contents
@admin.register(MysteryBag)
class MysteryBagAdmin(admin.ModelAdmin):
    list_display = ('title', 'vendor', 'price', 'quantity_available', 'is_active')
    list_filter = ('vendor', 'is_donation', 'is_active')
    search_fields = ('title', 'vendor__name')
    fields = (
        'vendor', 'title', 'description', 'price', 'quantity_available',
        'is_donation', 'pickup_start', 'pickup_end', 'date_posted',
        'hidden_contents', 'is_active'
    )

# 🛒 Reservation Admin
@admin.register(Reservation)
class ReservationAdmin(admin.ModelAdmin):
    list_display = (
        'user', 'bag', 'price_paid', 'payment_method', 'reserved_at', 'is_collected'
    )
    list_filter = ('is_collected', 'payment_method', 'reserved_at')
    search_fields = ('user__username', 'bag__title', 'bag__vendor__name')
    readonly_fields = ('reserved_at',)

# 👐 NGO Request Admin
@admin.register(NGORequest)
class NGORequestAdmin(admin.ModelAdmin):
    list_display = ('ngo', 'title', 'needed_by', 'num_people', 'is_fulfilled', 'created_at')
    list_filter = ('is_fulfilled', 'needed_by')
    search_fields = ('ngo__username', 'title')

# ⭐ Vendor Reviews
@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ('user', 'vendor', 'rating', 'created_at')
    list_filter = ('rating', 'created_at')
    search_fields = ('user__username', 'vendor__name', 'comment')

# 📍 User Locations
@admin.register(UserLocation)
class UserLocationAdmin(admin.ModelAdmin):
    list_display = ('user', 'name', 'latitude', 'longitude', 'created_at')
    search_fields = ('user__username', 'name')

# 🔐 Register Custom User
admin.site.register(CustomUser, CustomUserAdmin)
