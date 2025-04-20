class RdvModel {
  // final String doctorName;
  // final String specialty; // If you have the field in the backend
  // final String date;
  // final String time;
  // final String status;
  // final String type;
  // final String reason;

  // RdvModel({
  //   required this.doctorName,
  //   required this.specialty,
  //   required this.date,
  //   required this.time,
  //   required this.status,
  //   required this.type,
  //   required this.reason,
  // });

  final Map<String, String> data; // A map to hold dynamic key-value pairs

  RdvModel({required this.data});

  factory RdvModel.fromJson(Map<String, dynamic> json) {
    return RdvModel(
      data: {
        'doctorName': json["doctorName"] ?? '',
        'specialty': json["specialty"] ?? 'No specialty',
        'date': json["date"] ?? '',
        'time': json["time"] ?? '',
        'status': json["status"] ?? '',
        'type': json["type"] ?? '',
        'reason': json["reason"] ?? '',
      },
    );
  }
}
