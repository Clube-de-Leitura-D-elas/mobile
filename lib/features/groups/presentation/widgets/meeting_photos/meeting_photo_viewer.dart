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
    this.photos = const [],
    this.onDelete,
    this.onDownload,
  });

  final MeetingPhotoEntity photo;
  final int index;
  final int total;
  final List<MeetingPhotoEntity> photos;

  /// Nulo quando a participante não pode remover (só anfitriã/coordenação).
  final MeetingPhotoDeleter? onDelete;

  /// Permite trocar o `url_launcher` nos testes.
  final MeetingPhotoLauncher? onDownload;

  static Future<void> open(
    BuildContext context, {
    MeetingPhotoEntity? photo,
    List<MeetingPhotoEntity> photos = const [],
    required int index,
    required int total,
    MeetingPhotoDeleter? onDelete,
  }) {
    final gallery = photos.isEmpty ? [photo!] : photos;
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => MeetingPhotoViewer(
          photo: gallery[index],
          photos: gallery,
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
  late int _currentIndex = widget.index;

  MeetingPhotoEntity get _photo =>
      widget.photos.isEmpty ? widget.photo : widget.photos[_currentIndex];

  bool get _hasPrevious => _currentIndex > 0;
  bool get _hasNext =>
      _currentIndex <
      (widget.photos.isEmpty ? widget.total : widget.photos.length) - 1;

  void _showPrevious() {
    if (_hasPrevious) setState(() => _currentIndex--);
  }

  void _showNext() {
    if (_hasNext) setState(() => _currentIndex++);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final deleter = widget.onDelete;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          l10n.meetingPhotoViewerTitle(
            _currentIndex + 1,
            widget.photos.isEmpty ? widget.total : widget.photos.length,
          ),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) => Padding(
                  padding: EdgeInsets.only(top: context.spacing.s8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      InteractiveViewer(
                        child: Semantics(
                          image: true,
                          label: l10n.meetingPhotoSemanticLabel(
                            _currentIndex + 1,
                          ),
                          child: Image.network(
                            _photo.url,
                            width: constraints.maxWidth,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                ? child
                                : const SizedBox(
                                    height: 48,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(
                                  height: 48,
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                      if (_hasPrevious)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            tooltip: l10n.meetingPhotoPrevious,
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: 40,
                            ),
                            onPressed: _showPrevious,
                          ),
                        ),
                      if (_hasNext)
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            tooltip: l10n.meetingPhotoNext,
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 40,
                            ),
                            onPressed: _showNext,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_photo.caption case final caption?)
                if (caption.trim().isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      context.spacing.s16,
                      context.spacing.s8,
                      context.spacing.s16,
                      context.spacing.s16,
                    ),
                    color: Colors.white,
                    child: Text(
                      caption,
                      style: context.typography.bodyDefault.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ),
            ],
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
    final uri = Uri.tryParse(_photo.url);
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
      deleted = await deleter(_photo.id);
    } catch (_) {
      deleted = false;
    }
    if (!mounted) return;
    if (deleted) {
      Navigator.of(context).pop();
    } else {
      setState(() => _isDeleting = false);
    }
  }
}
