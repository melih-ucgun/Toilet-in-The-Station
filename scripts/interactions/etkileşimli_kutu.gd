extends StaticBody3D

# Oyuncu "E" tuşuna basınca RayCast bu fonksiyonu çalıştıracak
func etkilesim_yap():
	print("Kutuya dokunuldu! Güle güle kutu...")
	queue_free() # Kutuyu sahneden siler
