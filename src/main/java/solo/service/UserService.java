package solo.service;

import solo.dto.RegisterUserRequest;

import solo.response.RegisterUserResponse;

public interface UserService {
    RegisterUserResponse registerUser(RegisterUserRequest registerUserRequest);


}
