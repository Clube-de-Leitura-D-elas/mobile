import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_photo_delete_dialog.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

typedef MeetingPhotoDeleter = Future<bool> Function(String photoId);
typedef MeetingPhotoLauncher = Future<bool> Function(Uri uri);

class MeetingPhotoViewer extends StatefulWidget {
  const MeetingPhotoViewer({
    super.key,
    required this.photo,
    required this.index,
    required this.total,
    this.onDelete,
    this.onDownload,
  });

  final MeetingPhotoEntity photo;
  final int index;
  final int total;

  /// Nulo quando a participante não pode remover (só anfitriã/coordenação).
  final MeetingPhotoDeleter? onDelete;

  /// Permite trocar o `url_launcher` nos testes.
  final MeetingPhotoLauncher? onDownload;

  static Future<void> open(
    BuildContext context, {
    required MeetingPhotoEntity photo,
    required int index,
    required int total,
    MeetingPhotoDeleter? onDelete,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => MeetingPhotoViewer(
          photo: photo,
          index: index,
          total: total,
          onDelete: onDelete,
        ),
      ),
    );
  }

  @override
  State<MeetingPhotoViewer> createState() => _MeetingPhotoViewerState();
}

class _MeetingPhotoViewerState extends State<MeetingPhotoViewer> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final deleter = widget.onDelete;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          l10n.meetingPhotoViewerTitle(widget.index + 1, widget.total),
        ),
        actions: [
          IconButton(
            key: const ValueKey('meeting-photo-download'),
            tooltip: l10n.meetingPhotoDownload,
            icon: const Icon(Icons.download_outlined),
            onPressed: _download,
          ),
          if (deleter != null)
            IconButton(
              key: const ValueKey('meeting-photo-delete'),
              tooltip: l10n.meetingPhotoDelete,
              icon: _isDeleting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.delete_outline),
              onPressed: _isDeleting ? null : () => _delete(deleter),
            ),
        ],
      ),
      body: SafeArea(
        child: InteractiveViewer(
          child: Center(
            child: Semantics(
              image: true,
              label: l10n.meetingPhotoSemanticLabel(widget.index + 1),
              child: Image.network(
                widget.photo.url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const CircularProgressIndicator(color: Colors.white),
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _download() async {
    final launch =
        widget.onDownload ??
        (uri) => launcher.launchUrl(
          uri,
          mode: launcher.LaunchMode.externalApplication,
        );
    final uri = Uri.tryParse(widget.photo.url);
    var opened = false;
    try {
      opened = uri != null && await launch(uri);
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) {
      context.showErrorToast(context.l10n.meetingPhotoDownloadFailed);
    }
  }

  Future<void> _delete(MeetingPhotoDeleter deleter) async {
    final confirmed = await MeetingPhotoDeleteDialog.show(context);
    if (confirmed != true || !mounted) return;
    setState(() => _isDeleting = true);
    var deleted = false;
    try {
      deleted = await deleter(widget.photo.id);
    } finally {
      if (mounted && !deleted) setState(() => _isDeleting = false);
    }
    if (deleted && mounted) Navigator.of(context).pop();
  }
}
