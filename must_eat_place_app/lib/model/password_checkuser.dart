class PasswordCheckUser {
String? validatePassword(String value) {
  // 정규식 패턴 (한글 또는 영문+숫자 조합, 4자 이상 15자 이하)
  String pattern = r'^[가-힣a-zA-Z0-9]{4,15}$';
  RegExp regExp = RegExp(pattern);

  if (value.isEmpty) {
    return '비밀번호를 입력하세요';
  } else if (!regExp.hasMatch(value)) {
    return '비밀번호는 한글 또는 영문과 숫자를 포함한 4자 이상 15자 이내로 입력하세요.';
  } else {
    return null; // 유효한 비밀번호
  }
}

  String? validatePasswordConfirm(String password, String passwordConfirm) {
    if (passwordConfirm.isEmpty) {
      return '비밀번호 확인칸을 입력하세요';
    } else if (password != passwordConfirm) {
      return '입력한 비밀번호가 서로 다릅니다.';
    } else {
      return null;
    }
  }
}
