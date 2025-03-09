class RdvModel {
  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  final String status;
  final String image;

  RdvModel({
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.status,
    required this.image,
  });

  factory RdvModel.fromJson(Map<String, String> json) {
    return RdvModel(
      doctorName: json["doctorName"]!,
      specialty: json["specialty"]!,
      date: json["date"]!,
      time: json["time"]!,
      status: json["status"]!,
      image: json["image"]!,
    );
  }
}
