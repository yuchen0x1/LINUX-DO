import 'package:linux_do/models/topic_detail.dart';

class PollVote {
  final Polls? poll;
  final List<String>? vote;

  PollVote({this.poll, this.vote});

  factory PollVote.fromJson(Map<String, dynamic> json) {
    return PollVote(
      poll: json['poll'] != null ? Polls.fromJson(json['poll']) : null,
      vote: json['vote'] != null ? List<String>.from(json['vote']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'poll': poll?.toJson(),
      'vote': vote,
    };
  }
}

class PollVotersResponse {
  final Map<String, List<PollVoter>>? voters;

  PollVotersResponse({this.voters});

  factory PollVotersResponse.fromJson(Map<String, dynamic> json) {
    Map<String, List<PollVoter>>? votersMap;

    if (json['voters'] != null) {
      votersMap = {};
      (json['voters'] as Map<String, dynamic>).forEach((key, value) {
        votersMap![key] = List<PollVoter>.from(
            (value as List).map((x) => PollVoter.fromJson(x)));
      });
    }

    return PollVotersResponse(
      voters: votersMap,
    );
  }
}
