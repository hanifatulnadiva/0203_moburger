class ToppingModel{
  final int id;
  final String nama_Topping;
  final int harga;
  final String kategori;
  final bool tersedia;

  ToppingModel({
    required this.id,
    required this.nama_Topping,
    required this.harga,
    required this.kategori,
    required this.tersedia,
  });

  factory ToppingModel.fromJson(Map<String,dynamic> json){
    return ToppingModel(
      id: json['id'] ?? 0, 
      nama_Topping: json['nama_Topping'] ?? '',
      harga:json['harga'] ?? 0,
      kategori: json['kategori']?? '',
      tersedia: json['tersedia'] ?? false,
    );
  }
}