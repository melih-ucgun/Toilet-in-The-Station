extends StaticBody3D

@export var esya_adi: String = "Su Kutusu"
@export var ikon: Texture2D

# --- DÜZELTME BURADA ---
# Godot'nun oluşturduğu ismin (alttaki fonksiyonun) içini dolduruyoruz.
# Eski fonksiyonu silebilirsin.
func _on_interactablearea_on_interact() -> void:
	# Sahnede "Player" grubundaki karakteri bul
	var oyuncu = get_tree().get_first_node_in_group("Player")
	
	if oyuncu:
		etkilesim_yap(oyuncu)
	else:
		print("HATA: Oyuncu bulunamadı! Karakterine 'Player' grubu ekledin mi?")

# --- Etkileşim Fonksiyonu (Aynı kalacak) ---
func etkilesim_yap(oyuncu):
	if oyuncu.has_method("envantere_ekle"):
		oyuncu.envantere_ekle(esya_adi, ikon)
		print(esya_adi + " alındı!")
		queue_free() # Kutuyu sahneden sil


func _on_interactable_area_on_interact() -> void:
	pass # Replace with function body.
