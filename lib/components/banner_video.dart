import 'package:flutter/material.dart';
import 'package:youtube_downloader/screens/downloads.dart';
import 'package:youtube_downloader/styles/banner_video.dart' as style;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'information/search_error.dart';
import 'information/waiting_data.dart';

class BannerVideo extends StatelessWidget {
  final String url;

  const BannerVideo({required this.url, Key? key}) : super(key: key);

  String formatedTime(Duration time) {
    final hours = time.inHours;
    if (hours == 0) {
      final minutes = time.inMinutes;
      final seconds = time.inSeconds - minutes * 60;
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    } else {
      final minutes = time.inMinutes - hours * 60;
      final seconds = time.inSeconds - hours * 3600 - minutes * 60;
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  void addToDownloads(BuildContext context, Video video) {
    Downloads.add(video);

    const snackBar = SnackBar(
      content: Text('Realizando o download...', textAlign: TextAlign.center),
      duration: Duration(milliseconds: 800),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    var yt = YoutubeExplode();

    return FutureBuilder(
      future: yt.videos.get(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const WaitingData();
        } else if (snapshot.hasData) {
          final video = snapshot.data as Video;
          return buildBanner(context, video);
        } else {
          return const SearchError();
        }
      },
    );
  }

  Widget buildBanner(BuildContext context, Video video) {
    final timeBox = Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(formatedTime(video.duration!), style: style.BannerVideo.time),
    );

    final downloadButton = Container(
      decoration: const BoxDecoration(
        gradient: style.BannerVideo.gradientDownload,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        color: style.BannerVideo.colorIconDownload,
        onPressed: () {
          addToDownloads(context, video);
        },
        icon: const Icon(Icons.download),
      ),
    );

    final left = Expanded(
      flex: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(video.title, style: style.BannerVideo.title),
          const SizedBox(height: 10),
          Text(video.author, style: style.BannerVideo.channel),
        ],
      ),
    );

    final right = Expanded(
      child: Column(
        children: [
          downloadButton,
          const Spacer(),
          timeBox,
        ],
      ),
    );

    return Container(
      width: 480,
      height: 218,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
          image: NetworkImage(video.thumbnails.highResUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 0, 8),
              child: Row(
                children: <Widget>[
                  left,
                  right,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
