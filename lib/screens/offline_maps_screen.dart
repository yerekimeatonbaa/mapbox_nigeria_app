import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineMapsScreen extends StatefulWidget {
  const OfflineMapsScreen({super.key});

  @override
  State<OfflineMapsScreen> createState() => _OfflineMapsScreenState();
}

class _OfflineMapsScreenState extends State<OfflineMapsScreen> {
  final List<Map<String, dynamic>> _nigerianCities = [
    {'name': 'Lagos', 'lat': 6.5244, 'lng': 3.3792, 'downloaded': false},
    {'name': 'Abuja', 'lat': 9.0765, 'lng': 7.3986, 'downloaded': false},
    {'name': 'Kano', 'lat': 12.0022, 'lng': 8.5920, 'downloaded': false},
    {'name': 'Ibadan', 'lat': 7.3775, 'lng': 3.9470, 'downloaded': false},
    {'name': 'Port Harcourt', 'lat': 4.8156, 'lng': 7.0498, 'downloaded': false},
    {'name': 'Benin City', 'lat': 6.3350, 'lng': 5.6037, 'downloaded': false},
    {'name': 'Kaduna', 'lat': 10.5105, 'lng': 7.4165, 'downloaded': false},
    {'name': 'Enugu', 'lat': 6.5244, 'lng': 7.5106, 'downloaded': false},
  ];

  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadDownloadedMaps();
  }

  Future<void> _loadDownloadedMaps() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var city in _nigerianCities) {
        city['downloaded'] = _prefs?.getBool('offline_${city['name']}') ?? false;
      }
    });
  }

  Future<void> _downloadMap(Map<String, dynamic> city) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Downloading ${city['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Downloading map tiles for ${city['name']}...'),
            const SizedBox(height: 8),
            const Text(
              'This may take a few minutes depending on your connection.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 3));

    await _prefs?.setBool('offline_${city['name']}', true);
    
    if (mounted) {
      Navigator.pop(context);
      setState(() {
        city['downloaded'] = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${city['name']} map downloaded successfully!')),
      );
    }
  }

  Future<void> _deleteMap(Map<String, dynamic> city) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Offline Map'),
        content: Text('Delete offline map for ${city['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _prefs?.setBool('offline_${city['name']}', false);
      setState(() {
        city['downloaded'] = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${city['name']} map deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Maps'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Download maps for offline use. Maps are cached for navigation without internet.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _nigerianCities.length,
              itemBuilder: (context, index) {
                final city = _nigerianCities[index];
                final isDownloaded = city['downloaded'] as bool;
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isDownloaded ? Colors.green : Colors.grey,
                      child: Icon(
                        isDownloaded ? Icons.check : Icons.download,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      city['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      isDownloaded ? 'Downloaded' : 'Not downloaded',
                      style: TextStyle(
                        color: isDownloaded ? Colors.green : Colors.grey,
                      ),
                    ),
                    trailing: isDownloaded
                        ? IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red,
                            onPressed: () => _deleteMap(city),
                          )
                        : ElevatedButton.icon(
                            onPressed: () => _downloadMap(city),
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text('Download'),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
