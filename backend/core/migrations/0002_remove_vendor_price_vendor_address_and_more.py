# Generated by Django 5.2 on 2025-04-20 09:17

import django.db.models.deletion
import django.utils.timezone
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0001_initial'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='vendor',
            name='price',
        ),
        migrations.AddField(
            model_name='vendor',
            name='address',
            field=models.CharField(default='Default Address', max_length=255),
        ),
        migrations.AddField(
            model_name='vendor',
            name='average_rating',
            field=models.FloatField(default=0.0),
        ),
        migrations.AddField(
            model_name='vendor',
            name='delivery_available',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='vendor',
            name='delivery_time_minutes',
            field=models.PositiveIntegerField(default=30),
        ),
        migrations.AddField(
            model_name='vendor',
            name='latitude',
            field=models.FloatField(default=33.8886),
        ),
        migrations.AddField(
            model_name='vendor',
            name='longitude',
            field=models.FloatField(default=35.4955),
        ),
        migrations.AlterField(
            model_name='vendor',
            name='description',
            field=models.TextField(blank=True),
        ),
        migrations.CreateModel(
            name='MysteryBag',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=100)),
                ('description', models.TextField()),
                ('quantity_available', models.PositiveIntegerField(default=1)),
                ('price', models.DecimalField(decimal_places=2, max_digits=6)),
                ('is_donation', models.BooleanField(default=False)),
                ('pickup_start', models.TimeField()),
                ('pickup_end', models.TimeField()),
                ('date_posted', models.DateTimeField(default=django.utils.timezone.now)),
                ('is_active', models.BooleanField(default=True)),
                ('vendor', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='mystery_bags', to='core.vendor')),
            ],
        ),
        migrations.CreateModel(
            name='NGORequest',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=100)),
                ('description', models.TextField()),
                ('num_people', models.PositiveIntegerField()),
                ('needed_by', models.DateField()),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('is_fulfilled', models.BooleanField(default=False)),
                ('ngo', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='Reservation',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('reserved_at', models.DateTimeField(auto_now_add=True)),
                ('is_collected', models.BooleanField(default=False)),
                ('price_paid', models.DecimalField(decimal_places=2, default=0.0, max_digits=6)),
                ('bag', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='core.mysterybag')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
    ]
