extends StaticBody3D

# Kaynağın kendi rezervi (Sınırsız istiyorsan bu kısmı değiştirebiliriz)
@export var kaynak_rezervi: int = 100 
@export var tek_seferde_verilen: int = 10 # Her basışta kaçar kaçar versin?

# InteractableArea düğümünü bul
@onready var etkilesim_alani = $InteractableArea

func _ready():
	# InteractableArea'nın sinyalini dinle
	# (Senin sisteminde sinyal adı 'on_interact' idi)
	etkilesim_alani.on_interact.connect(_on_etkilesim)

func _on_etkilesim():
	print("Kaynağa dokunuldu!")
	
	# Kaynakta su bitti mi?
	if kaynak_rezervi <= 0:
		print("Bu kaynak kurumuş!")
		return

	# Oyuncuyu bul (InteractableArea zaten oyuncuyu algılıyor ama 
	# burada global bir 'Player' referansı veya grup üzerinden bulabiliriz)
	var player = get_tree().get_first_node_in_group("Player")
	
	if player:
		# Oyuncuya yakıt vermeyi dene
		# Elimizde ne kadar varsa veya ayarlı miktar kadar sunuyoruz
		var sunulan_miktar = min(tek_seferde_verilen, kaynak_rezervi)
		
		# Oyuncunun 'yakit_ekle' fonksiyonunu çağır ve kaç tane alabildiğini öğren
		var alinan = player.yakit_ekle(sunulan_miktar)
		
		# Kaynaktan düş
		kaynak_rezervi -= alinan
		print("Kaynakta kalan: ", kaynak_rezervi)
		
		# Görsel geri bildirim (Ses çalabilir, su seviyesi azalabilir vs.)
		if alinan > 0:
			# Buraya bir "gluk gluk" sesi veya partikül efekti ekleyebilirsin
			pass
