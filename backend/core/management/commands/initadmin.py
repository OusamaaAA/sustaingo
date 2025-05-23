from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from django.db import IntegrityError

class Command(BaseCommand):
    help = 'Creates an initial superuser and runs migrations'

    def handle(self, *args, **kwargs):
        from django.core.management import call_command
        call_command('makemigrations')
        call_command('migrate')

        User = get_user_model()
        try:
            if not User.objects.filter(username='admin').exists():
                User.objects.create_superuser(
                    username='admin',
                    email='admin@example.com',
                    password='admin123'
                )
                self.stdout.write(self.style.SUCCESS('Superuser created!'))
            else:
                self.stdout.write(self.style.WARNING('Superuser already exists.'))
        except IntegrityError:
            self.stdout.write(self.style.ERROR('Error creating superuser.'))