from django.contrib import admin
from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView

from core.views import (
    # 🔐 Auth & Profile
    MyTokenObtainPairView, register_user, get_user_profile,
    get_user_locations, create_user_location,
    update_user_profile,

    # 🏪 Vendor
    get_vendors, get_vendor_profile, update_vendor_profile,
    get_vendor_my_bags, get_vendor_dashboard_summary,
    get_vendor_reservations, get_vendor_reviews,
    create_vendor_profile,

    # 🛍️ Mystery Bags
    get_all_mystery_bags, get_mystery_bags_by_vendor,
    create_mystery_bag, update_mystery_bag, delete_mystery_bag,

    # 📦 Reservations
    reserve_bag, get_my_reservations, mark_reservation_collected,

    # 💬 Reviews
    get_reviews_by_vendor, create_review,

    # 🧑‍🤝‍🧑 NGOs
    get_ngo_dashboard_summary, get_donation_bags,
    reserve_donation_bag, get_ngo_profile, update_ngo_profile,
    create_ngo_profile, public_ngos,

    # 🔒 Private/Extended
    get_vendor_private_bags, update_private_mystery_bag,
    admin_get_all_bags, admin_get_bag_details,

    # 🧑‍💼 Admin Stats
    get_admin_dashboard_stats,
    list_users, toggle_user_active, delete_user,
    list_reviews, delete_review,
    list_bags, delete_bag, toggle_bag_active,
    list_reservations, delete_reservation,
    vendor_analytics,
    reservation_analytics,
    bag_analytics, review_analytics,user_analytics,
)


urlpatterns = [
    # 🔐 Auth & Profile
    path('admin/', admin.site.urls),
    path('api/login/', MyTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/register/', register_user),
    path('api/profile/', get_user_profile),
    path('api/user-locations/', get_user_locations, name='get_user_locations'),
    path('api/user-locations/create/', create_user_location, name='create_user_location'),

    # 🏪 Vendor Public + Private
    path('api/vendors/', get_vendors),
    path('api/vendor-profile/', get_vendor_profile),
    path('api/vendor-profile/update/', update_vendor_profile),
    path('api/vendor-my-bags/', get_vendor_my_bags),
    path('api/vendor-dashboard-summary/', get_vendor_dashboard_summary),
    path('api/vendor-reservations/', get_vendor_reservations),
    path('api/vendor-reviews/', get_vendor_reviews),
    path('api/vendor-private/bags/', get_vendor_private_bags),
    path('api/vendor-private/bags/<int:bag_id>/update/', update_private_mystery_bag),
    path('api/create_vendor_profile/', create_vendor_profile),


    # 🛍️ Mystery Bags
    path('api/bags/', get_all_mystery_bags),
    path('api/vendors/<int:vendor_id>/bags/', get_mystery_bags_by_vendor),
    path('api/bags/create/', create_mystery_bag),
    path('api/bags/<int:bag_id>/update/', update_mystery_bag),
    path('api/bags/<int:bag_id>/delete/', delete_mystery_bag),

    # 📦 Reservations
    path('api/bags/<int:bag_id>/reserve/', reserve_bag),
    path('api/my-reservations/', get_my_reservations),
    path('api/reservations/<int:reservation_id>/collected/', mark_reservation_collected),

    # 💬 Reviews
    path('api/vendors/<int:vendor_id>/reviews/', get_reviews_by_vendor),
    path('api/vendors/<int:vendor_id>/reviews/create/', create_review),

    # 🧑‍🤝‍🧑 NGOs
    path('api/get_ngo_dashboard_summary/', get_ngo_dashboard_summary),
    path('api/get_donation_bags/', get_donation_bags),
    path('api/reserve_donation_bag/<int:bag_id>/', reserve_donation_bag),
    path('api/get_ngo_profile/', get_ngo_profile),
    path('api/update_ngo_profile/', update_ngo_profile),
    path('api/create_ngo_profile/', create_ngo_profile),
    path('api/public_ngos/', public_ngos),

    # 🧑‍💼 Admin APIs
    path('api/admin-dashboard-stats/', get_admin_dashboard_stats),
    path('api/admin/users/', list_users),
    path('api/admin/user/<int:user_id>/toggle-active/', toggle_user_active),
    path('api/admin/user/<int:user_id>/delete/', delete_user),
    path('api/admin/reviews/', list_reviews),
    path('api/admin/review/<int:review_id>/delete/', delete_review),
    path('api/admin/bags/', list_bags),
    path('api/admin/bag/<int:bag_id>/delete/', delete_bag),
    path('api/admin/bag/<int:bag_id>/toggle-active/', toggle_bag_active),
    path('api/admin/reservations/', list_reservations),
    path('api/admin/reservation/<int:reservation_id>/delete/', delete_reservation),
    path('api/vendor-analytics/', vendor_analytics),
    path('api/reservation-analytics/', reservation_analytics),
    path('api/bag-analytics/', bag_analytics),
    path('api/review-analytics/', review_analytics),
    path('api/user-analytics/', user_analytics),


    # 🧾 Admin Private (Extended)
    path('api/admin-private/bags/', admin_get_all_bags),
    path('api/admin-private/bags/<int:bag_id>/', admin_get_bag_details),

    path('api/profile/update/', update_user_profile, name='update_user_profile'),
]
