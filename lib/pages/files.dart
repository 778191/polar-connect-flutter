import 'dart:io';
import 'package:polar_connect/widgets/custom_buttons.dart';
import 'package:polar_connect/widgets/custom_colors.dart';
import 'package:polar_connect/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileBrowser extends StatefulWidget {
  @override
  _FileBrowserState createState() => _FileBrowserState();
}

class _FileBrowserState extends State<FileBrowser> {
  List<String> _filenames = [];

  @override
  void initState() {
    super.initState();
    _refreshFiles();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'File Browser',
      body: _filenames.isEmpty
          ? InfoBox(
              text:
                  "Your files will be displayed here. Record some signals to get started!")
          : RefreshIndicator(
              onRefresh: () async {
                _refreshFiles();
              },
              child: ListView.builder(
                itemCount: _filenames.length,
                itemBuilder: (context, index) {
                  final filename = _filenames[index].split('/').last;
                  return Dismissible(
                    background: Container(
                      color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.delete, color: Colors.white),
                          SizedBox(width: 24),
                        ],
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    key: Key(filename),
                    onDismissed: (direction) {
                      // Remove the item from the data source.
                      setState(() {
                        _removeFile(_filenames[index]);
                        _filenames.removeAt(index);
                      });
                    },
                    child: ListTile(
                      title: Text(
                        filename,
                        style: GoogleFonts.roboto(
                          color: CustomColors.tertiary,
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      subtitle: Text(
                        "Tap to share",
                        style: GoogleFonts.roboto(
                          color: CustomColors.tertiary,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => _shareFile(_filenames[index]),
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _refreshFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      final filenames =
          files.where((file) => file is File).map((file) => file.path).toList();
      setState(() {
        _filenames = filenames;
      });
    } catch (e) {
      print('Error refreshing results: $e');
    }
  }

  void _removeFile(String filename) async {
    try {
      final file = await File(filename);
      await file.delete();
    } catch (e) {
      print('Error removing file: $e');
    }
  }

  Future<void> _shareFile(String filename) async {
    try {
      final result = await Share.shareXFiles([XFile(filename)]);

      if (result.status == ShareResultStatus.success) {
        print('File shared successfully');
      }
    } catch (e) {
      print('Error sharing file: $e');
    }
  }
}
