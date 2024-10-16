package solo.service;


import solo.dto.LoginRequest;
import solo.dto.RegisterUserRequest;
import solo.response.LoginResponse;
import solo.response.RegisterUserResponse;

public interface UserService {
    RegisterUserResponse registerUser(RegisterUserRequest registerUserRequest);

    LoginResponse login(LoginRequest loginRequest);
}
