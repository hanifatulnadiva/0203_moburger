class MenuModel{
  final int id;
  final String nama_menu;
  final int harga;
  final String image_url;
  final String kategori;
  final bool tersedia;
  final String deskripsi;

  MenuModel({
    required this.id,
    required this.nama_menu,
    required this.harga,
    required this.image_url,
    required this.kategori,
    required this.tersedia,
    required this.deskripsi,
  });

  factory MenuModel.fromJson(Map<String,dynamic> json){
    return MenuModel(
      id: json['id'] ?? 0, 
      nama_menu: json['nama_menu'] ?? '',
      harga:json['harga'] ?? 0,
      image_url: json['image_url'] ?? '',
      kategori: json['kategori']?? '',
      tersedia: json['tersedia'] ?? false,
      deskripsi: json['deskripsi'] ?? ''
    );
  }
}