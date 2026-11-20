import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const SasitApp());
}

class SasitTheme {
  const SasitTheme(this.name, this.seedColor, this.brightness);

  final String name;
  final Color seedColor;
  final Brightness brightness;
}

const _themes = [
  SasitTheme('Terracotta', Color(0xFFB65D45), Brightness.light),
  SasitTheme('Lavender', Color(0xFF7662A7), Brightness.light),
  SasitTheme('Midnight', Color(0xFF63B8A7), Brightness.dark),
];

class SasitApp extends StatefulWidget {
  const SasitApp({super.key});

  @override
  State<SasitApp> createState() => _SasitAppState();
}

class _SasitAppState extends State<SasitApp> {
  int _themeIndex = 0;
  String? _displayName;
  String? _handle;

  @override
  Widget build(BuildContext context) {
    final theme = _themes[_themeIndex];
    final colors = ColorScheme.fromSeed(
      seedColor: theme.seedColor,
      brightness: theme.brightness,
    );
    return MaterialApp(
      title: 'SASit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colors,
        scaffoldBackgroundColor: theme.brightness == Brightness.dark
            ? const Color(0xFF171819)
            : const Color(0xFFFAF8F5),
        appBarTheme: AppBarTheme(
          backgroundColor: theme.brightness == Brightness.dark
              ? const Color(0xFF171819)
              : const Color(0xFFFAF8F5),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: _displayName == null
          ? WelcomeScreen(
              onCreateAccount: (name) {
                final accountHandle = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
                setState(() {
                  _displayName = name;
                  _handle = '@${accountHandle.isEmpty ? 'newfriend' : accountHandle}';
                });
              },
              onContinueAsGuest: () => setState(() {
                _displayName = 'Alex Morgan';
                _handle = '@alexmorgan';
              }),
            )
          : HomeShell(
              displayName: _displayName!,
              handle: _handle!,
              themeIndex: _themeIndex,
              onThemeChanged: (index) => setState(() => _themeIndex = index),
            ),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    required this.onCreateAccount,
    required this.onContinueAsGuest,
    super.key,
  });

  final ValueChanged<String> onCreateAccount;
  final VoidCallback onContinueAsGuest;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _createAccount() {
    if (!_formKey.currentState!.validate()) return;
    widget.onCreateAccount(_nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 92,
                      width: 92,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
                      child: Icon(Icons.spa_rounded, size: 46, color: colors.onPrimaryContainer),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'SASit',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share the good stuff. Stay for the real stuff.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 30),
                    Text('Create your account', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Your name', prefixIcon: Icon(Icons.person_outline_rounded)),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Enter your name.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.mail_outline_rounded)),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        return email.contains('@') && email.contains('.')
                            ? null
                            : 'Enter a valid email address.';
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                      validator: (value) => (value?.length ?? 0) < 8 ? 'Use at least 8 characters.' : null,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _createAccount,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Text('Create account'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: widget.onContinueAsGuest,
                      child: const Text('Explore as a guest'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Prototype account details stay on this device for this session only.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SocialPost {
  SocialPost({
    required this.name,
    required this.handle,
    required this.avatarUrl,
    required this.imageUrl,
    required this.caption,
    required this.location,
    required this.tags,
    required this.likes,
    required this.mediaType,
    this.liked = false,
    List<String>? comments,
  }) : comments = comments ?? [];

  final String name;
  final String handle;
  final String avatarUrl;
  final String imageUrl;
  final String caption;
  final String location;
  final List<String> tags;
  final String mediaType;
  int likes;
  bool liked;
  final List<String> comments;
}

class ChatMessage {
  ChatMessage(this.text, {this.isMine = false});

  final String text;
  final bool isMine;
}

class ChatThread {
  ChatThread({
    required this.title,
    required this.subtitle,
    required this.avatarUrl,
    required this.isGroup,
    required this.messages,
  });

  final String title;
  final String subtitle;
  final String avatarUrl;
  final bool isGroup;
  final List<ChatMessage> messages;

  String get preview => messages.isEmpty ? subtitle : messages.last.text;
}

final _initialPosts = <SocialPost>[
  SocialPost(
    name: 'Maya Chen',
    handle: '@mayainmotion',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop',
    imageUrl: 'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=1200&h=900&fit=crop',
    caption: 'A little reminder to take the long way home. The mountains were showing off today.',
    location: 'Dolomites, Italy',
    tags: const ['@leo.m', '@natasha'],
    likes: 284,
    comments: ['This light is unreal ✨', 'Adding this to my list!'],
    mediaType: 'Photo',
  ),
  SocialPost(
    name: 'Noah Williams',
    handle: '@noahoutside',
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&h=120&fit=crop',
    imageUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1200&h=900&fit=crop',
    caption: 'The kind of morning that makes you forget to check your phone.',
    location: 'Big Sur, California',
    tags: const ['@ellie'],
    likes: 156,
    comments: ['Perfect morning, Noah.'],
    mediaType: 'Video',
  ),
  SocialPost(
    name: 'Priya Kapoor',
    handle: '@priyamakes',
    avatarUrl: 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=120&h=120&fit=crop',
    imageUrl: 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=1200&h=900&fit=crop',
    caption: 'Sunday flowers from the little market around the corner 🌷',
    location: 'Brooklyn, New York',
    tags: const ['@sana', '@jules'],
    likes: 92,
    comments: [],
    mediaType: 'Photo',
  ),
];

final _initialChats = <ChatThread>[
  ChatThread(
    title: 'Weekend hikers',
    subtitle: 'Group · 6 members',
    avatarUrl: 'https://images.unsplash.com/photo-1472396961693-142e6e269027?w=120&h=120&fit=crop',
    isGroup: true,
    messages: [
      ChatMessage('Maya: Trail photos are up!'),
      ChatMessage('Who is in for next weekend?'),
    ],
  ),
  ChatThread(
    title: 'Maya Chen',
    subtitle: 'Active now',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop',
    isGroup: false,
    messages: [
      ChatMessage('That view was worth the early start.'),
      ChatMessage('Absolutely. Let’s do it again soon!', isMine: true),
    ],
  ),
  ChatThread(
    title: 'Priya Kapoor',
    subtitle: 'Seen recently',
    avatarUrl: 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=120&h=120&fit=crop',
    isGroup: false,
    messages: [
      ChatMessage('Sending you the flower market address 🌷'),
    ],
  ),
  ChatThread(
    title: 'Photo club',
    subtitle: 'Group · 12 members',
    avatarUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=120&h=120&fit=crop',
    isGroup: true,
    messages: [
      ChatMessage('This week’s prompt: little details'),
    ],
  ),
];

class HomeShell extends StatefulWidget {
  const HomeShell({
    required this.displayName,
    required this.handle,
    required this.themeIndex,
    required this.onThemeChanged,
    super.key,
  });

  final String displayName;
  final String handle;
  final int themeIndex;
  final ValueChanged<int> onThemeChanged;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tabIndex = 0;
  final List<SocialPost> _posts = List.of(_initialPosts);
  final List<ChatThread> _chats = List.of(_initialChats);
  Timer? _timer;
  Duration? _timeRemaining;
  bool _lastPostMode = false;
  bool _feedEnded = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(Duration duration) {
    _timer?.cancel();
    setState(() => _timeRemaining = duration);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = _timeRemaining ?? Duration.zero;
      if (remaining.inSeconds <= 1) {
        timer.cancel();
        setState(() => _timeRemaining = Duration.zero);
        _showTimeUp();
      } else {
        setState(() => _timeRemaining = remaining - const Duration(seconds: 1));
      }
    });
  }

  Future<void> _showTimerSetup() async {
    final duration = await showModalBottomSheet<Duration>(
      context: context,
      showDragHandle: true,
      builder: (context) => const TimerSetupSheet(),
    );
    if (duration != null) _startTimer(duration);
  }

  Future<void> _showTimeUp() async {
    final viewOneMore = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.hourglass_bottom_rounded, size: 32),
        title: const Text('Your time is up'),
        content: const Text(
          'You set a limit for today. Would you like to stop now, or see one last post?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Stop now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('One last post'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() {
      _timeRemaining = null;
      _lastPostMode = viewOneMore == true;
      _feedEnded = viewOneMore != true;
      _tabIndex = 0;
    });
  }

  void _finishFeed() {
    setState(() {
      _lastPostMode = false;
      _feedEnded = true;
    });
  }

  Future<void> _createPost() async {
    final post = await showModalBottomSheet<SocialPost>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => CreatePostSheet(
        displayName: widget.displayName,
        handle: widget.handle,
      ),
    );
    if (post != null) setState(() => _posts.insert(0, post));
  }

  Future<void> _showComments(SocialPost post) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => CommentsSheet(
        post: post,
        onAdd: (comment) => setState(() => post.comments.add(comment)),
      ),
    );
  }

  Future<void> _sharePost(SocialPost post) async {
    final thread = await showModalBottomSheet<ChatThread>(
      context: context,
      showDragHandle: true,
      builder: (context) => ShareSheet(chats: _chats),
    );
    if (thread == null || !mounted) return;
    setState(() {
      thread.messages.add(ChatMessage('Shared a post: ${post.caption}', isMine: true));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Post shared with ${thread.title}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      FeedScreen(
        posts: _posts,
        timeRemaining: _timeRemaining,
        lastPostMode: _lastPostMode,
        feedEnded: _feedEnded,
        onTimer: _showTimerSetup,
        onCreatePost: _createPost,
        onLike: (post) => setState(() {
          post.liked = !post.liked;
          post.likes += post.liked ? 1 : -1;
        }),
        onComments: _showComments,
        onShare: _sharePost,
        onFinishFeed: _finishFeed,
        onBrowseAgain: () => setState(() {
          _feedEnded = false;
          _lastPostMode = false;
        }),
      ),
      SearchScreen(posts: _posts),
      ChatsScreen(
        chats: _chats,
        onOpenChat: (thread) => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => ChatDetailScreen(thread: thread),
          ),
        ),
      ),
      ProfileScreen(
        posts: _posts,
        displayName: widget.displayName,
        handle: widget.handle,
        themeIndex: widget.themeIndex,
        onThemeChanged: widget.onThemeChanged,
        onTimer: _showTimerSetup,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), selectedIcon: Icon(Icons.chat_bubble_rounded), label: 'Chats'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class FeedScreen extends StatelessWidget {
  const FeedScreen({
    required this.posts,
    required this.timeRemaining,
    required this.lastPostMode,
    required this.feedEnded,
    required this.onTimer,
    required this.onCreatePost,
    required this.onLike,
    required this.onComments,
    required this.onShare,
    required this.onFinishFeed,
    required this.onBrowseAgain,
    super.key,
  });

  final List<SocialPost> posts;
  final Duration? timeRemaining;
  final bool lastPostMode;
  final bool feedEnded;
  final VoidCallback onTimer;
  final VoidCallback onCreatePost;
  final ValueChanged<SocialPost> onLike;
  final ValueChanged<SocialPost> onComments;
  final ValueChanged<SocialPost> onShare;
  final VoidCallback onFinishFeed;
  final VoidCallback onBrowseAgain;

  @override
  Widget build(BuildContext context) {
    final visiblePosts = lastPostMode && posts.isNotEmpty ? posts.take(1) : posts;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SASit',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -1.2),
        ),
        actions: [
          if (timeRemaining != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Chip(
                  avatar: const Icon(Icons.hourglass_bottom_rounded, size: 17),
                  label: Text(_formatDuration(timeRemaining!)),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          IconButton(
            tooltip: 'Set mindful timer',
            onPressed: onTimer,
            icon: const Icon(Icons.timer_outlined),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16, left: 4),
            child: CircleAvatar(
              radius: 17,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=120&h=120&fit=crop'),
            ),
          ),
        ],
      ),
      floatingActionButton: feedEnded
          ? null
          : FloatingActionButton.extended(
              onPressed: onCreatePost,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Create'),
            ),
      body: feedEnded
          ? _DoneForToday(onBrowseAgain: onBrowseAgain)
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'A little more present.',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lastPostMode ? 'Here is your one last post.' : 'Good things from people you know.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        if (lastPostMode)
                          Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Material(
                              color: Theme.of(context).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    const Icon(Icons.self_improvement_rounded),
                                    const SizedBox(width: 10),
                                    const Expanded(child: Text('Enjoy this last moment, then take a break.')),
                                    TextButton(onPressed: onFinishFeed, child: const Text('Done')),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (posts.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('No posts yet. Share a little moment.')),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = visiblePosts.elementAt(index);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: PostCard(
                              post: post,
                              onLike: () => onLike(post),
                              onComments: () => onComments(post),
                              onShare: () => onShare(post),
                            ),
                          );
                        },
                        childCount: visiblePosts.length,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class PostCard extends StatelessWidget {
  const PostCard({
    required this.post,
    required this.onLike,
    required this.onComments,
    required this.onShare,
    super.key,
  });

  final SocialPost post;
  final VoidCallback onLike;
  final VoidCallback onComments;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
            child: Row(
              children: [
                CircleAvatar(radius: 21, backgroundImage: NetworkImage(post.avatarUrl)),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        '${post.handle}  ·  ${post.location}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 1.14,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  post.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: colors.secondaryContainer,
                    child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 42)),
                  ),
                ),
                if (post.mediaType == 'Video')
                  Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.black.withOpacity(.45), shape: BoxShape.circle),
                      child: const Padding(
                        padding: EdgeInsets.all(13),
                        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34),
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(.48), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      post.mediaType,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: onLike,
                      icon: Icon(post.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                      color: post.liked ? colors.error : null,
                    ),
                    Text('${post.likes}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: onComments,
                      icon: const Icon(Icons.mode_comment_outlined),
                    ),
                    Text('${post.comments.length}'),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Share in a chat',
                      visualDensity: VisualDensity.compact,
                      onPressed: onShare,
                      icon: const Icon(Icons.send_outlined),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${post.name}  ', style: const TextStyle(fontWeight: FontWeight.w700)),
                        TextSpan(text: post.caption),
                      ],
                    ),
                  ),
                ),
                if (post.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 9, 0, 0),
                    child: Wrap(
                      spacing: 6,
                      children: post.tags
                          .map((tag) => Text(tag, style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600)))
                          .toList(),
                    ),
                  ),
                if (post.comments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 8, 0, 0),
                    child: InkWell(
                      onTap: onComments,
                      child: Text(
                        'View all ${post.comments.length} comments',
                        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({required this.posts, super.key});

  final List<SocialPost> posts;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = widget.posts.where((post) {
      final searchable = '${post.name} ${post.handle} ${post.caption} ${post.location} ${post.tags.join(' ')}'.toLowerCase();
      return searchable.contains(_query.toLowerCase());
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Explore', style: TextStyle(fontWeight: FontWeight.w700))),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
              child: TextField(
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: InputDecoration(
                  hintText: 'Search people, places, moments',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        results[index].imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => ColoredBox(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          child: const Icon(Icons.image_outlined),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          width: double.infinity,
                          color: Colors.black.withOpacity(.42),
                          child: Text(
                            results[index].location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                childCount: results.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: .9,
              ),
            ),
          ),
          if (results.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('No moments found. Try another search.')),
            ),
        ],
      ),
    );
  }
}

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({required this.chats, required this.onOpenChat, super.key});

  final List<ChatThread> chats;
  final ValueChanged<ChatThread> onOpenChat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your people', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        children: [
          Text('CHATS & ROOMS', style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.2)),
          const SizedBox(height: 12),
          for (final chat in chats)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => onOpenChat(chat),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(chat.avatarUrl),
                  child: chat.isGroup ? const Icon(Icons.group_rounded, color: Colors.white) : null,
                ),
                title: Text(chat.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(chat.preview, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
          const SizedBox(height: 20),
          Text('A GOOD PLACE TO START', style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(Icons.forum_outlined, color: Theme.of(context).colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Share a post with a friend or catch up in one of your rooms.')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({required this.thread, super.key});

  final ChatThread thread;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => widget.thread.messages.add(ChatMessage(text, isMine: true)));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final thread = widget.thread;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(radius: 18, backgroundImage: NetworkImage(thread.avatarUrl)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(thread.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Text(thread.isGroup ? thread.subtitle : 'Active now', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: thread.messages.length,
              itemBuilder: (context, index) {
                final message = thread.messages[index];
                return Align(
                  alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 290),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                    decoration: BoxDecoration(
                      color: message.isMine
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isMine ? Theme.of(context).colorScheme.onPrimary : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Write a message',
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(onPressed: _send, icon: const Icon(Icons.arrow_upward_rounded)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.posts,
    required this.displayName,
    required this.handle,
    required this.themeIndex,
    required this.onThemeChanged,
    required this.onTimer,
    super.key,
  });

  final List<SocialPost> posts;
  final String displayName;
  final String handle;
  final int themeIndex;
  final ValueChanged<int> onThemeChanged;
  final VoidCallback onTimer;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final myPosts = posts.where((post) => post.handle == handle).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your profile', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=180&h=180&fit=crop'),
                ),
                const SizedBox(height: 12),
                Text(displayName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                Text(handle, style: TextStyle(color: colors.onSurfaceVariant)),
                const SizedBox(height: 10),
                const Text('Collecting little moments & taking the scenic route.', textAlign: TextAlign.center),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ProfileStat(value: '${myPosts.length}', label: 'posts'),
                    const SizedBox(width: 36),
                    const _ProfileStat(value: '248', label: 'friends'),
                    const SizedBox(width: 36),
                    const _ProfileStat(value: '12', label: 'tagged'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text('MAKE SASIT YOURS', style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.2)),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('App theme'),
                  subtitle: Text(_themes[themeIndex].name),
                  trailing: DropdownButton<int>(
                    value: themeIndex,
                    underline: const SizedBox.shrink(),
                    onChanged: (value) {
                      if (value != null) onThemeChanged(value);
                    },
                    items: List.generate(
                      _themes.length,
                      (index) => DropdownMenuItem(value: index, child: Text(_themes[index].name)),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 54),
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Mindful time limit'),
                  subtitle: const Text('Set a daily browsing timer'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: onTimer,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('YOUR MOMENTS', style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.2)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: myPosts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: .85,
            ),
            itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                myPosts[index].imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => ColoredBox(
                  color: colors.secondaryContainer,
                  child: const Icon(Icons.image_outlined),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class TimerSetupSheet extends StatefulWidget {
  const TimerSetupSheet({super.key});

  @override
  State<TimerSetupSheet> createState() => _TimerSetupSheetState();
}

class _TimerSetupSheetState extends State<TimerSetupSheet> {
  double _minutes = 20;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 4, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Make room for offline', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Choose how long you would like to browse.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 18),
            Center(
              child: Text(
                '${_minutes.round()} min',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Slider(
              value: _minutes,
              min: 5,
              max: 120,
              divisions: 23,
              label: '${_minutes.round()} minutes',
              onChanged: (value) => setState(() => _minutes = value),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context, Duration(minutes: _minutes.round())),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start my timer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentsSheet extends StatefulWidget {
  const CommentsSheet({required this.post, required this.onAdd, super.key});

  final SocialPost post;
  final ValueChanged<String> onAdd;

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addComment() {
    final comment = _controller.text.trim();
    if (comment.isEmpty) return;
    widget.onAdd(comment);
    setState(() {});
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .68,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Comments', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            ),
            const Divider(height: 1),
            Expanded(
              child: widget.post.comments.isEmpty
                  ? const Center(child: Text('Start the conversation.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.post.comments.length,
                      itemBuilder: (context, index) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                        title: Text(index.isEven ? 'Jamie Rivera' : 'Sam Lee'),
                        subtitle: Text(widget.post.comments[index]),
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + MediaQuery.viewInsetsOf(context).bottom),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _addComment(),
                      decoration: InputDecoration(
                        hintText: 'Add a comment…',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  IconButton(onPressed: _addComment, icon: const Icon(Icons.send_rounded)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({
    required this.displayName,
    required this.handle,
    super.key,
  });

  final String displayName;
  final String handle;

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final _captionController = TextEditingController();
  final _imageController = TextEditingController();
  final _tagsController = TextEditingController();
  String _mediaType = 'Photo';
  bool _useSampleImage = true;

  @override
  void dispose() {
    _captionController.dispose();
    _imageController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _publish() {
    final caption = _captionController.text.trim();
    if (caption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a caption before sharing.')));
      return;
    }
    final imageUrl = _imageController.text.trim();
    if (!_useSampleImage && imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a media URL to your post.')));
      return;
    }
    final tags = _tagsController.text
        .split(RegExp(r'[\s,]+'))
        .where((tag) => tag.isNotEmpty)
        .map((tag) => tag.startsWith('@') ? tag : '@$tag')
        .toList();
    Navigator.pop(
      context,
      SocialPost(
        name: widget.displayName,
        handle: widget.handle,
        avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=120&h=120&fit=crop',
        imageUrl: _useSampleImage
            ? 'https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?w=1200&h=900&fit=crop'
            : imageUrl,
        caption: caption,
        location: 'Shared with friends',
        tags: tags,
        likes: 0,
        mediaType: _mediaType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Share a moment', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('A photo, a video, or something you want to remember.'),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Photo', label: Text('Photo'), icon: Icon(Icons.photo_outlined)),
                  ButtonSegment(value: 'Video', label: Text('Video'), icon: Icon(Icons.videocam_outlined)),
                ],
                selected: {_mediaType},
                onSelectionChanged: (selection) => setState(() => _mediaType = selection.first),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Use a sample image'),
                value: _useSampleImage,
                onChanged: (value) => setState(() => _useSampleImage = value),
              ),
              if (!_useSampleImage)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: _imageController,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(labelText: 'Public media URL', prefixIcon: Icon(Icons.link_rounded)),
                  ),
                ),
              TextField(
                controller: _captionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Write a caption', alignLabelWithHint: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Tag people', hintText: 'maya, noah'),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _publish,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Share with friends'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShareSheet extends StatelessWidget {
  const ShareSheet({required this.chats, super.key});

  final List<ChatThread> chats;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share in a chat', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            for (final chat in chats)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundImage: NetworkImage(chat.avatarUrl)),
                title: Text(chat.title),
                subtitle: Text(chat.isGroup ? 'Room' : 'Personal chat'),
                onTap: () => Navigator.pop(context, chat),
              ),
          ],
        ),
      ),
    );
  }
}

class _DoneForToday extends StatelessWidget {
  const _DoneForToday({required this.onBrowseAgain});

  final VoidCallback onBrowseAgain;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: colors.secondaryContainer, shape: BoxShape.circle),
              child: Icon(Icons.spa_outlined, size: 48, color: colors.onSecondaryContainer),
            ),
            const SizedBox(height: 22),
            Text(
              'You’re all done for today.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'Enjoy your time away from your phone. The good stuff is happening out there.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 22),
            OutlinedButton(onPressed: onBrowseAgain, child: const Text('Back to my feed')),
          ],
        ),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (duration.inHours > 0) {
    return '${duration.inHours}:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}
