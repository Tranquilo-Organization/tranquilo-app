import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tranquilo_app/core/helpers/constants.dart';
import 'package:tranquilo_app/core/helpers/extensions.dart';
import 'package:tranquilo_app/core/theming/styles.dart';
import 'package:tranquilo_app/core/helpers/spacing.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tranquilo_app/core/theming/colors_manger.dart';
import 'package:tranquilo_app/core/widgets/switch_widget.dart';
import 'package:tranquilo_app/core/helpers/shared_pref_helper.dart';
import 'package:tranquilo_app/features/community/logic/posts_cubit/posts_cubit.dart';
import 'package:tranquilo_app/features/community/ui/widgets/create_post_app_bar.dart';
import 'package:tranquilo_app/features/community/data/models/post_models/create_post_request_model.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {

  final TextEditingController _postController = TextEditingController();
  bool isAnonymous = false;
  String? userEmail = 'guest@example.com';
  String? userName = 'Guest';

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
    _fetchUserName();
  }

  Future<void> _fetchUserEmail() async {
    userEmail = await SharedPrefHelper.getEmail();
    setState(() {});
  }
  Future<void> _fetchUserName() async {
    userName = await SharedPrefHelper.getString(SharedPrefKeys.userName);
    setState(() {});
  }

  void _createPost() async {
    final postContent = _postController.text;
    if (postContent.isNotEmpty) {
      final email =
      isAnonymous ? 'anonymous' : userEmail ?? 'guest@example.com';

      context.read<PostsCubit>().createPost(
        CreatePostRequestModel(
          postText: postContent,
          userEmail: email,
        ),
      );
      _postController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post content cannot be empty!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            verticalSpace(16),
            CreatePostAppBar(onPost: _createPost),
            verticalSpace(16),
            Container(
              width: double.infinity,
              height: 47.h,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: ColorsManager.oceanBlue.withOpacity(0.14),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Post anonymously',
                      style: TextStyles.font14OceanBlueRegular,
                    ),
                    SwitchWidget(
                      value: isAnonymous,
                      onChanged: (value) {
                        setState(() {
                          isAnonymous = value;
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
            verticalSpace(20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  ClipOval(
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      color: Colors.transparent,
                      child: SvgPicture.asset(
                        isAnonymous
                            ? 'assets/svgs/anonymous.svg'
                            : 'assets/svgs/default_profile.svg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  horizontalSpace(12),
                  Text(
                    isAnonymous
                        ? 'Anonymous'
                        : (userName!),
                    style: TextStyles.font16JetBlackMedium,
                  ),
                ],
              ),
            ),
            verticalSpace(20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: TextField(
                controller: _postController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: isAnonymous
                      ? 'Submit an anonymous post...'
                      : "What's on your mind?",
                  hintStyle: TextStyles.font14JetBlackRegular,
                  border: InputBorder.none,
                ),
              ),
            ),
            verticalSpace(20),
            BlocConsumer<PostsCubit, PostsState>(
              listener: (context, state) {
                state.maybeWhen(
                  createPostSuccess: (response) {
                    SharedPrefHelper.setData('post_id', response.postId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: ColorsManager.green,
                        content: Text(
                          'Post created successfully!',
                          style: TextStyles.font14JetBlackMedium.copyWith(
                            color: ColorsManager.white,
                          ),
                        ),
                      ),
                    );
                    context.pop();
                  },
                  createPostError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                        Text('Failed to create post: ${error.message}'),
                      ),
                    );
                  },
                  orElse: () {},
                );
              },
              builder: (context, state) {
                return state.maybeWhen(
                  createPostLoading: () => const CircularProgressIndicator(),
                  orElse: () => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}

