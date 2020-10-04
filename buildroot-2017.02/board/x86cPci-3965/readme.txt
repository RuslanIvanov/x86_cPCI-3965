# '+' в работе, '-+' не используется, но в экспл.на объекте и отработано, '--'не исп. 
# от 250718 не использ.
# --текущая настройка сборки x86cPCI_min_defconfig
# --текущая настройка ядра cPCI-3965_linux_thr_ipx_iconv-4.9.6_min

# сборка с учетом временной зоны от 25072018 (используется она в НН, на ubuntu 14.04 надо x86cPCI_min_TZ_MSK_GLIB_defconfig из за проблем с libiconv):
# -+текущая настройка сборки x86cPCI_min_TZ_MSK_defconfig для вер. проекта 1.4.2 с вкл. libiconv (4033600 /package/customize/arx/bzImage_for1.4.2)
# -+текущая настройка сборки x86cPCI_min_TZ_MSK_NOlibiconv_defconfig для вер. проекта 1.4.2.1 со своей перекодировкой, без использования iptables & forwarding (
#  текущая настройка ядра cPCI-3965_linux_thr_ipx_iconv-4.9.6_min_TZ )

# iptables & forwarding - последняя на стенде и в ННовгороде январь. 2019г:
# -настройка сборки x86cPCI_min_TZ_MSK_NOlibiconv_IPTAB_NN_defconfig для вер. проекта 1.4.2.1 со своей перекодировкой для ННовгорода
# -+настройка ядра cPCI-3965_linux_thr_ipx_iconv-4.9.6_min_TZ_IPTAB

# iptables & forwarding в работе по Минску
# +текущая настройка сборки x86cPCI_min_TZ_MSK_NOlibiconv_IPTAB_defconfig со своей перекодировкой для HHовгорода и Минска
# +текущая настройка ядра cPCI-3965_linux_thr_ipx_iconv-4.9.6_min_TZ_IPTAB 

