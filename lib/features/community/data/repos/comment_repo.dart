import 'package:tranquilo_app/core/network/api_result.dart';
import 'package:tranquilo_app/core/network/api_service.dart';
import 'package:tranquilo_app/core/network/api_error_handler.dart';
import 'package:tranquilo_app/features/community/data/models/comment_models/get_comment_response_model.dart';
import 'package:tranquilo_app/features/community/data/models/comment_models/create_comment_request_model.dart';
import 'package:tranquilo_app/features/community/data/models/comment_models/create_comment_response_model.dart';

class CommentRepo {
  final ApiService _apiService;

  CommentRepo(this._apiService);

  /// Fetch community comments
  Future<ApiResult<GetCommentResponseModel>> getComments() async {
    try {
      final response = await _apiService.communityCpmments();
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  /// Create a new comment
  Future<ApiResult<CreateCommentResponseModel>> createComment(
      CreateCommentRequestModel createCommentRequestModel) async {
    try {
      final response =
          await _apiService.createComment(createCommentRequestModel);
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
