class ToppingModel{
  final int id;
  final String nama_topping;
  final int harga;
  final String kategori;
  final bool tersedia;

  ToppingModel({
    required this.id,
    required this.nama_topping,
    required this.harga,
    required this.kategori,
    required this.tersedia,
  });

  factory ToppingModel.fromJson(Map<String,dynamic> json){
    return ToppingModel(
      id: json['id'] ?? 0, 
      nama_topping: json['nama_topping'] ?? '',
      harga:json['harga'] ?? 0,
      kategori: json['kategori']?? '',
      tersedia: json['tersedia'] ?? false,
    );
  }
}