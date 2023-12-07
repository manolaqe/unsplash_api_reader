import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Unspash API Reader',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Unspash API Reader'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _page = 1;
  final List<UnsplashPhoto> _photos = <UnsplashPhoto>[];
  bool isLoading = true;
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_scrollListener);
    _loadItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final double offset = _controller.offset;
    final double maxExtent = _controller.position.maxScrollExtent;

    if (!isLoading && offset > maxExtent * 0.8) {
      _loadItems();
    }
  }

  Future<void> _loadItems() async {
    setState(() {
      isLoading = true;
    });

    final Client client = Client();

    final Uri uri = Uri.parse('https://api.unsplash.com/photos');

    final Response response = await client.get(
        uri.replace(queryParameters: <String, String>{'page': '$_page'}),
        headers: {
          HttpHeaders.authorizationHeader:
              'Client-ID LhmGVHNY9GK4bQtdRigmldamkO1VCOmvEbfEsHIk59k'
        });

    List<dynamic> json = jsonDecode(response.body) as List<dynamic>;

    for (final dynamic item in json) {
      _photos.add(UnsplashPhoto.fromJson(item as Map<String, dynamic>));
    }

    _page++;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(
          child: Text(widget.title),
        ),
      ),
      body: Builder(
        builder: (BuildContext buildContext) {
          return ListView.builder(
            controller: _controller,
            itemCount: _photos.length,
            itemBuilder: (context, index) {
              final UnsplashPhoto photo = _photos[index];
              return Column(
                children: [
                  Image.network(
                    photo.urls!.regular!,
                    loadingBuilder:
                        (BuildContext context, Widget widget, loadingProgress) {
                      if (loadingProgress == null) {
                        return widget;
                      }

                      return Center(
                        child: CircularProgressIndicator(
                            value: loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes! ??
                                1),
                      );
                    },
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(photo.user!.profileImage!.small),
                    ),
                    title: Text(photo.user!.name!),
                    subtitle: Text(photo.description ?? ''),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class UnsplashPhoto {
  final String? id;
  final String? createdAt;
  final String? updatedAt;
  final int? width;
  final int? height;
  final String? color;
  final String? blurHash;
  final int? likes;
  final bool? likedByUser;
  final String? description;
  final User? user;
  final List<Collection> currentUserCollections;
  final Urls? urls;
  final Links? links;

  UnsplashPhoto.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        width = json['width'],
        height = json['height'],
        color = json['color'],
        blurHash = json['blur_hash'],
        likes = json['likes'],
        likedByUser = json['liked_by_user'],
        description = json['description'],
        user = User.fromJson(json['user']),
        currentUserCollections = (json['current_user_collections'] as List)
            .map((i) => Collection.fromJson(i))
            .toList(),
        urls = Urls.fromJson(json['urls']),
        links = Links.fromJson(json['links']);
}

class User {
  final String? id;
  final String? username;
  final String? name;
  final String? portfolioUrl;
  final String? bio;
  final String? location;
  final int? totalLikes;
  final int? totalPhotos;
  final int? totalCollections;
  final String? instagramUsername;
  final String? twitterUsername;
  final ProfileImage? profileImage;
  final Links? links;

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        name = json['name'],
        portfolioUrl = json['portfolio_url'],
        bio = json['bio'],
        location = json['location'],
        totalLikes = json['total_likes'],
        totalPhotos = json['total_photos'],
        totalCollections = json['total_collections'],
        instagramUsername = json['instagram_username'],
        twitterUsername = json['twitter_username'],
        profileImage = ProfileImage.fromJson(json['profile_image']),
        links = Links.fromJson(json['links']);
}

class ProfileImage {
  final String small;
  final String medium;
  final String large;

  ProfileImage.fromJson(Map<String, dynamic> json)
      : small = json['small'],
        medium = json['medium'],
        large = json['large'];
}

class Links {
  final String? self;
  final String? html;
  final String? photos;
  final String? likes;
  final String? portfolio;

  Links.fromJson(Map<String, dynamic> json)
      : self = json['self'],
        html = json['html'],
        photos = json['photos'],
        likes = json['likes'],
        portfolio = json['portfolio'];
}

class Collection {
  final int? id;
  final String? title;
  final String? publishedAt;
  final String? lastCollectedAt;
  final String? updatedAt;
  final dynamic coverPhoto;
  final dynamic user;

  Collection.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        publishedAt = json['published_at'],
        lastCollectedAt = json['last_collected_at'],
        updatedAt = json['updated_at'],
        coverPhoto = json['cover_photo'],
        user = json['user'];
}

class Urls {
  final String? raw;
  final String? full;
  final String? regular;
  final String? small;
  final String? thumb;

  Urls.fromJson(Map<String, dynamic> json)
      : raw = json['raw'],
        full = json['full'],
        regular = json['regular'],
        small = json['small'],
        thumb = json['thumb'];
}
