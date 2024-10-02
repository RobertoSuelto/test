#!/bin/ash

# Limpiar la carpeta temporal
rm -rf /home/container/tmp/*

# Iniciar PHP-FPM
echo "⟳ Starting PHP-FPM..."
/usr/sbin/php-fpm8 --fpm-config /home/container/php-fpm/php-fpm.conf --daemonize

# Verificar si Nginx tiene activado el módulo stream
echo "⟳ Verificando módulos de Nginx..."
nginx -V 2>&1 | grep -- 'with-stream'

if [ $? -eq 0 ]; then
  echo "✓ Módulo stream habilitado en Nginx"
else
  echo "✗ Módulo stream no habilitado en Nginx"
fi

# Iniciar Nginx con la configuración personalizada
echo "⟳ Starting Nginx..."
/usr/sbin/nginx -c /home/container/nginx/nginx.conf -p /home/container/

# Mensaje de estado del inicio de Nginx
if [ $? -eq 0 ]; then
  echo "✓ Nginx iniciado con éxito"
else
  echo "✗ Error al iniciar Nginx"
fi
