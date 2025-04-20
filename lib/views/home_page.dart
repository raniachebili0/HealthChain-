import 'package:admin_health_chain/services/role_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/services/user_service.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final RoleService _roleService = RoleService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _allUsers = [];
  Future<Map<String, dynamic>>? _userFuture;
  final TextEditingController _userIdController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showAllUsers = true;
  String? _expandedUserId;
  Map<String, Map<String, dynamic>> _analysisResults = {};
  bool _isAnalyzing = false;
  String? _currentAnalyzingUserId;
  
  // Animation controllers
  late AnimationController _pulseController;
  final List<Color> _medicalColors = [
    const Color(0xFF1A75FF), // Primary blue
    const Color(0xFF0052CC), // Darker blue
    const Color(0xFFE6F0FF), // Light blue
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadCurrentUser();
    await _loadAllUsers();
  }

  Future<void> _loadCurrentUser() async {
    setState(() => _isLoading = true);
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId != null) {
        setState(() => _userFuture = _userService.getUserById(userId));
      }
    } catch (e) {
      _showErrorDialog('Erreur de chargement', 'Impossible de charger l\'utilisateur: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAllUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _userService.getAllUsers();
      setState(() => _allUsers = users);
    } catch (e) {
      _showErrorDialog('Erreur de chargement', 'Impossible de charger la liste des utilisateurs: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _analyzeDocument(String userId, String imageUrl) async {
    setState(() {
      _isAnalyzing = true;
      _currentAnalyzingUserId = userId;
    });

    try {
      final result = await _userService.analyzeDocument(imageUrl);

      setState(() {
        _analysisResults[userId] = result;
      });

      _showAnalysisDialog(context, result);

    } catch (e) {
      _showErrorDialog('Résultat d\'analyse', e.toString());
    } finally {
      setState(() {
        _isAnalyzing = false;
        _currentAnalyzingUserId = null;
      });
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title),
        backgroundColor: Colors.red[50],
        titleTextStyle: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAnalysisDialog(BuildContext context, Map<String, dynamic> analysis) {
    final title = analysis['title'] ?? 'Titre inconnu';
    final isFraud = analysis['Fraude'] == true;
    final confidence = analysis['confidenceScore']?.toString() ?? 'Non défini';
    final observations = analysis['observations'] ?? 'Aucune observation.';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isFraud 
                ? [Colors.red.shade50, Colors.white] 
                : [Colors.green.shade50, Colors.white],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.1),
                        child: Icon(
                          isFraud ? Icons.warning_amber_rounded : Icons.verified,
                          color: isFraud ? Colors.red : Colors.green,
                          size: 36,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      isFraud ? 'Document Suspect' : 'Document Authentique',
                      style: TextStyle(
                        color: isFraud ? Colors.red[700] : Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnalysisInfoRow(Icons.description, "Titre", title),
                    const SizedBox(height: 12),
                    _buildAnalysisInfoRow(
                      Icons.shield, 
                      "Confiance", 
                      "$confidence%",
                      textColor: isFraud ? Colors.red[700] : Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 12),
                    _buildAnalysisInfoRow(Icons.remove_red_eye, "Observations", ""),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0),
                      child: Text(
                        observations,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: _medicalColors[0],
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text(
                  'Fermer',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisInfoRow(IconData icon, String label, String value, {Color? textColor, FontWeight? fontWeight}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: _medicalColors[1]),
        const SizedBox(width: 12),
        Text(
          "$label : ",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: _medicalColors[1],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: fontWeight ?? FontWeight.normal,
              fontSize: 14,
              color: textColor ?? Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisRow(String label, String value, {bool isImportant = false, bool? isValid}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
                color: isValid == true 
                    ? Colors.green[800]
                    : isValid == false 
                        ? Colors.lightGreen[800] 
                        : Colors.red[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleExpandUser(String userId) {
    setState(() {
      if (_expandedUserId == userId) {
        _expandedUserId = null;
      } else {
        _expandedUserId = userId;
      }
    });
  }

  void _handleStatusChange(BuildContext context, String userId, String newStatus) async {
    try {
      await _userService.changeUserStatus(userId, newStatus);
      _loadInitialData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                newStatus == 'valide' ? Icons.check_circle : Icons.cancel,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              const Text('Statut modifié avec succès !'),
            ],
          ),
          backgroundColor: newStatus == 'valide' ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      _showErrorDialog('Erreur', 'Échec du changement de statut: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.medical_services, color: _medicalColors[0]),
            const SizedBox(width: 10),
            const Text(
              "Gestion Utilisateurs",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        foregroundColor: _medicalColors[0],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        actions: [ 
          Tooltip(
            message: _showAllUsers ? "Voir un utilisateur" : "Voir tous les utilisateurs",
            child: IconButton(
              icon: Icon(_showAllUsers ? Icons.person : Icons.people),
              color: _medicalColors[0],
              onPressed: () => setState(() {
                _showAllUsers = !_showAllUsers;
                _expandedUserId = null;
              }),
            ),
          ),
          Tooltip(
            message: "Actualiser",
            child: IconButton(
              icon: const Icon(Icons.refresh),
              color: _medicalColors[0],
              onPressed: _loadInitialData,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_medicalColors[2], Colors.white],
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMedicalLoadingAnimation(),
            const SizedBox(height: 20),
            Text(
              'Chargement des données...',
              style: TextStyle(
                fontSize: 16,
                color: _medicalColors[0],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    if (_errorMessage != null) return _buildErrorView();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          Expanded(
            child: _showAllUsers ? _buildAllUsersList() : _buildSingleUserView(),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalLoadingAnimation() {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _medicalColors[0].withOpacity(0.2 + (_pulseController.value * 0.3)),
                    width: 8,
                  ),
                ),
              );
            },
          ),
          // Inner circle
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _medicalColors[0].withOpacity(0.4 + (_pulseController.value * 0.3)),
                    width: 6,
                  ),
                ),
              );
            },
          ),
          // Medical cross
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _pulseController.value * math.pi / 10,
                child: Icon(
                  Icons.add,
                  size: 70,
                  color: _medicalColors[0].withOpacity(0.7 + (_pulseController.value * 0.3)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextField(
          controller: _userIdController,
          decoration: InputDecoration(
            labelText: "Rechercher par ID",
            labelStyle: TextStyle(color: _medicalColors[0]),
            border: InputBorder.none,
            suffixIcon: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return IconButton(
                  icon: Icon(
                    Icons.search,
                    color: _medicalColors[0].withOpacity(0.7 + (_pulseController.value * 0.3)),
                  ),
                  onPressed: () {
                    if (_userIdController.text.isNotEmpty) {
                      setState(() {
                        _showAllUsers = false;
                        _expandedUserId = null;
                        _userFuture = _userService.getUserById(_userIdController.text.trim());
                      });
                    }
                  },
                );
              },
            ),
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          cursorColor: _medicalColors[0],
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _showAllUsers = false;
                _expandedUserId = null;
                _userFuture = _userService.getUserById(value.trim());
              });
            }
          },
        ),
      ),
    );
  }

  

  Widget _buildAllUsersList() {
    if (_allUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: _medicalColors[0].withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun utilisateur disponible',
              style: TextStyle(
                fontSize: 18,
                color: _medicalColors[0],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _allUsers.length,
      itemBuilder: (context, index) {
        final user = _allUsers[index];
        final isExpanded = _expandedUserId == user['_id'];
        final status = user['status']?.toString().toLowerCase() ?? '';
        Color statusColor;
        
        switch (status) {
          case 'valide':
            statusColor = Colors.green;
            break;
          case 'en cours':
            statusColor = Colors.orange;
            break;
          case 'refuse':
            statusColor = Colors.red;
            break;
          default:
            statusColor = Colors.grey;
        }
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: isExpanded 
                    ? _medicalColors[0].withOpacity(0.2)
                    : Colors.black.withOpacity(0.05),
                blurRadius: isExpanded ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isExpanded ? _medicalColors[0].withOpacity(0.5) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _toggleExpandUser(user['_id']),
                    borderRadius: BorderRadius.vertical(
                      top: const Radius.circular(15),
                      bottom: Radius.circular(isExpanded ? 0 : 15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _medicalColors[0].withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: user['photo'] != null 
                                ? Image.network(
                                    _convertImageUrl(user['photo']),
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: _medicalColors[0],
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) => 
                                      const Icon(Icons.person, size: 40, color: Colors.grey),
                                  )
                                : const Icon(Icons.person, size: 40, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user['name'] ?? 'Nom inconnu',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user['email'] ?? 'Email inconnu',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (status.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: statusColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    _getStatusText(status),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: _medicalColors[0],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox(height: 0),
                  secondChild: _buildUserDetails(user),
                  crossFadeState: isExpanded 
                      ? CrossFadeState.showSecond 
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserDetails(Map<String, dynamic> user) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _roleService.getRoleById(user['roleId'].toString()),
      builder: (context, roleSnapshot) {
        if (roleSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: _medicalColors[0]),
            ),
          );
        }
        
        if (roleSnapshot.hasError || !roleSnapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Erreur de chargement du rôle',
              style: TextStyle(color: Colors.red[700]),
            ),
          );
        }

        final roleName = roleSnapshot.data!['name']?.toString().toLowerCase() ?? '';
        final isPatient = roleName == 'patient';
        final currentStatus = user['status']?.toString().toLowerCase();

        return Container(
          decoration: BoxDecoration(
            color: _medicalColors[2].withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(15),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfoSection(user, roleSnapshot.data!),
                
                if (currentStatus == 'en cours')
                  _buildUserActionButtons(context, user['_id']),
                
                if (roleName == 'practitioner')
                  _buildPractitionerInfoSection(user),
                  
                if (isPatient)
                  _buildPatientInfoSection(user),
                
                _buildPhotoSection(
                  'Photo de licence', 
                  user['photo'],
                  context,
                  user['_id'],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfoSection(Map<String, dynamic> user, Map<String, dynamic> role) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_pin, color: _medicalColors[0]),
                const SizedBox(width: 8),
                Text(
                  'Informations personnelles',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: _medicalColors[1],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRowWithIcon(Icons.fingerprint, 'ID', user['_id'] ?? 'Non renseigné'),
            _buildDetailRowWithIcon(Icons.email, 'Email', user['email'] ?? 'Non renseigné'),
            _buildDetailRowWithIcon(Icons.cake, 'Date de naissance', user['birthDate'] ?? 'Non renseignée'),
            _buildDetailRowWithIcon(Icons.location_on, 'Adresse', user['address'] ?? 'Non renseignée'),
            _buildDetailRowWithIcon(Icons.phone, 'Téléphone', user['telecom'] ?? 'Non renseigné'),
            _buildDetailRowWithIcon(
              Icons.verified_user, 
              'Statut', 
              user['active'] ? 'Actif' : 'Inactif',
              valueColor: user['active'] ? Colors.green : Colors.orange,
            ),
            _buildDetailRowWithIcon(
              Icons.badge, 
              'Rôle', 
              role['name'] ?? 'Non renseigné',
              valueColor: _medicalColors[0],
            ),
            if (user['status'] != null)
              _buildDetailRowWithIcon(
                Icons.how_to_reg, 
                'Statut du compte', 
                _getStatusText(user['status']),
                valueColor: _getStatusColor(user['status']),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserActionButtons(BuildContext context, String userId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      color: _medicalColors[0].withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.admin_panel_settings, color: _medicalColors[0]),
                const SizedBox(width: 8),
                Text(
                  'Actions administratives',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _medicalColors[1],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.check_circle,
                  label: 'Accepter',
                  color: Colors.green,
                  onPressed: () => _handleStatusChange(context, userId, 'valide'),
                ),
                  _buildActionButton(
                  icon: Icons.cancel,
                  label: 'Refuser',
                  color: Colors.red[700]!,
                  onPressed: () => _handleStatusChange(context, userId, 'refuse'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 3,
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildPractitionerInfoSection(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, color: _medicalColors[0]),
                const SizedBox(width: 8),
                Text(
                  'Informations professionnelles',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: _medicalColors[1],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRowWithIcon(
              Icons.medical_information, 
              'Spécialisation', 
              user['specialization'] ?? 'Non renseignée',
            ),
            _buildDetailRowWithIcon(
              Icons.badge, 
              'Numéro de licence', 
              user['licenseNumber'] ?? 'Non renseigné',
              valueColor: _medicalColors[0],
            ),
            _buildDetailRowWithIcon(Icons.info, 'Bio', user['doctorbio'] ?? 'Non renseignée'),
            _buildDetailRowWithIcon(Icons.access_time, 'Horaire', user['doctorhoraire'] ?? 'Non renseigné'),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoSection(Map<String, dynamic> user) {
    final medicalRecordsCount = user['MedicalRecords']?.length ?? 0;
    final appointmentsCount = user['appointments']?.length ?? 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder_shared, color: _medicalColors[0]),
                const SizedBox(width: 8),
                Text(
                  'Dossier médical',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: _medicalColors[1],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildMedicalInfoCard(
                    icon: Icons.description,
                    title: 'Dossiers médicaux',
                    value: medicalRecordsCount.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMedicalInfoCard(
                    icon: Icons.calendar_month,
                    title: 'Rendez-vous',
                    value: appointmentsCount.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _medicalColors[2],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _medicalColors[0].withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: _medicalColors[0], size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: _medicalColors[1],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _medicalColors[0],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(String label, String? photoUrl, BuildContext context, String userId) {
    final analysisResult = _analysisResults[userId];
    final isAnalyzed = analysisResult != null;
    final isLoadingAnalysis = _isAnalyzing && _currentAnalyzingUserId == userId;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.image, color: _medicalColors[0]),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: _medicalColors[1],
                      ),
                    ),
                  ],
                ),
                if (photoUrl != null)
                  ElevatedButton.icon(
                    icon: isLoadingAnalysis 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: isAnalyzed ? 1.0 : 1.0 + (_pulseController.value * 0.1),
                                child: Icon(
                                  isAnalyzed ? Icons.visibility : Icons.verified_user,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                    label: Text(isAnalyzed ? 'Voir analyse' : 'Vérification'),
                    onPressed: isLoadingAnalysis 
                        ? null 
                        : () => isAnalyzed 
                            ? _showAnalysisDialog(context, analysisResult)
                            : _analyzeDocument(userId, photoUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAnalyzed ? _medicalColors[0] : Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: photoUrl != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            _convertImageUrl(photoUrl),
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: _medicalColors[0],
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => 
                              _buildErrorPlaceholder(),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showFullScreenImage(context, photoUrl),
                              splashColor: _medicalColors[0].withOpacity(0.3),
                              highlightColor: Colors.transparent,
                              child: Center(
                                child: AnimatedOpacity(
                                  opacity: 0.7,
                                  duration: const Duration(milliseconds: 200),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.fullscreen,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : _buildEmptyPlaceholder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                _convertImageUrl(imageUrl),
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Container(
      color: _medicalColors[2].withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Aucune photo disponible',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.red[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            const SizedBox(height: 12),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                color: Colors.red[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _convertImageUrl(String url) {
    return url.replaceAll('10.0.2.2', 'localhost');
  }

  String _getStatusText(String? status) {
    if (status == null) return 'Non défini';
    switch (status.toLowerCase()) {
      case 'en cours': return 'En attente';
      case 'valide': return 'Validé';
      case 'refuse': return 'Rejeté';
      default: return status;
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'en cours': return Colors.orange;
      case 'valide': return Colors.green;
      case 'refuse': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildDetailRowWithIcon(IconData icon, String label, String? value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Non renseigné',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleUserView() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMedicalLoadingAnimation(),
                const SizedBox(height: 20),
                Text(
                  'Chargement des données utilisateur...',
                  style: TextStyle(
                    fontSize: 16,
                    color: _medicalColors[0],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: TextStyle(color: Colors.red[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                  onPressed: () {
                    setState(() {
                      _userFuture = _userService.getUserById(_userIdController.text.trim());
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _medicalColors[0],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        if (!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_search, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 24),
                Text(
                  'Utilisateur non trouvé',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Aucun utilisateur ne correspond à l\'ID recherché',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.people),
                  label: const Text('Voir tous les utilisateurs'),
                  onPressed: () {
                    setState(() {
                      _showAllUsers = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _medicalColors[0],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        return Card(
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildUserDetails(snapshot.data!),
          ),
        );
      },
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("Réessayer"),
            onPressed: _loadInitialData,
            style: ElevatedButton.styleFrom(
              backgroundColor: _medicalColors[0],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// Animation médical servant de widget de chargement (peut être utilisé dans d'autres écrans)
class MedicalLoadingAnimation extends StatefulWidget {
  final Color color;
  final double size;

  const MedicalLoadingAnimation({
    Key? key,
    this.color = const Color(0xFF1A75FF),
    this.size = 150,
  }) : super(key: key);

  @override
  _MedicalLoadingAnimationState createState() => _MedicalLoadingAnimationState();
}

class _MedicalLoadingAnimationState extends State<MedicalLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing circles
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double delay = index * 0.3;
                final double animValue = (((_controller.value + delay) % 1.0) < 1.0)
                    ? ((_controller.value + delay) % 1.0)
                    : 1.0;
                
                return Opacity(
                  opacity: 1.0 - animValue,
                  child: Transform.scale(
                    scale: 0.5 + (animValue * 0.5),
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.color.withOpacity(0.7),
                          width: 6 * (1 - animValue),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          
          // Medical symbol
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: Icon(
                  Icons.monitor_heart_outlined,
                  size: widget.size * 0.5,
                  color: widget.color,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}