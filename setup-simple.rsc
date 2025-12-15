# Упрощенная настройка Mikrotik для VLESS через SOCKS
# Этот вариант использует policy routing без SOCKS клиента на Mikrotik

# ============================================
# НАСТРОЙКИ - ИЗМЕНИТЕ ПЕРЕД ПРИМЕНЕНИЕМ
# ============================================
# IP адрес сервера с sing-box
:global proxyServer "10.0.2.15"

# ============================================
# 1. Очистка старых правил (опционально)
# ============================================
# /ip firewall address-list remove [find list=blocked-sites]
# /ip firewall mangle remove [find comment="Mark blocked sites traffic"]
# /ip firewall nat remove [find comment~"proxy"]
# /ip route remove [find comment="Route via proxy server"]

# ============================================
# 2. Список заблокированных сайтов
# ============================================

/ip firewall address-list
add list=blocked-sites address=facebook.com
add list=blocked-sites address=instagram.com
add list=blocked-sites address=twitter.com
add list=blocked-sites address=x.com
add list=blocked-sites address=telegram.org
add list=blocked-sites address=t.me
add list=blocked-sites address=discord.com
add list=blocked-sites address=youtube.com
add list=blocked-sites address=youtu.be
add list=blocked-sites address=googlevideo.com
add list=blocked-sites address=whatsapp.com
add list=blocked-sites address=reddit.com
add list=blocked-sites address=medium.com

# ============================================
# 3. Маркировка трафика
# ============================================

/ip firewall mangle
add chain=prerouting dst-address-list=blocked-sites action=mark-connection \
    new-connection-mark=proxy-conn passthrough=yes comment="Mark blocked connections"
add chain=prerouting connection-mark=proxy-conn action=mark-routing \
    new-routing-mark=to-proxy passthrough=no comment="Mark blocked routing"

# ============================================
# 4. Маршрут через прокси
# ============================================

/ip route
add dst-address=0.0.0.0/0 gateway=$proxyServer routing-mark=to-proxy \
    distance=1 comment="Route via proxy server"

# ============================================
# 5. Source NAT для прокси трафика
# ============================================

/ip firewall nat
add chain=srcnat connection-mark=proxy-conn action=masquerade \
    comment="Masquerade proxy traffic"

:log info "Mikrotik proxy routing configured"
:put "Done! Blocked sites will route via $proxyServer"
