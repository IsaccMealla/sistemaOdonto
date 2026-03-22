# Generated manually on 2025-12-12

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('coreapi', '0010_contactosemergencia_deleted_at_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='pacientes',
            name='ci',
            field=models.CharField(blank=True, max_length=20, null=True, verbose_name='Cédula de Identidad'),
        ),
    ]
