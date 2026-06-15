class MenuModel{
  final String id;
  final String nama_menu;
  final int harga;
  final String image_url;
  final String kategori;
  final bool tersedia;
  final String deskripsi;
  final String createdAt;

  MenuModel({
    required this.id,
    required this.nama_menu,
    required this.harga,
    required this.image_url,
    required this.kategori,
    required this.tersedia,
    required this.deskripsi,
    required this.createdAt,

  });
  MenuModel copyWith({bool? tersedia}) {
  return MenuModel(
    id: id,
    nama_menu: nama_menu,
    harga: harga,
    image_url: image_url,
    kategori: kategori,
    tersedia: tersedia ?? this.tersedia,
    deskripsi: deskripsi,
    // Pastikan createdAt menyertakan nilai asli dari objek ini
    createdAt: this.createdAt, 
  );
}

  factory MenuModel.fromJson(Map<String,dynamic> json){
    return MenuModel(
      id: json['id'] ?? '', 
      nama_menu: json['nama_menu'] ?? '',
      harga:json['harga'] ?? 0,
      image_url: json['image_url'] ?? '',
      kategori: json['kategori']?? '',
      tersedia: json['tersedia'] ?? false,
      deskripsi: (json['deskripsi'] is String && !json['deskripsi'].toString().contains("Instance")) 
               ? json['deskripsi'] 
               : '',
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String()
    );
  }
  @override
  List<Object?> get props=>[id,nama_menu, harga, image_url, kategori, tersedia, deskripsi, createdAt];
}