package solo.service;


import org.springframework.stereotype.Service;
import solo.dto.LoginRequest;
import solo.dto.RegisterUserRequest;
import solo.models.User;
import solo.repository.UserRepository;
import solo.response.LoginResponse;
import solo.response.RegisterUserResponse;

@Service
public class UserServiceImpl implements UserService{
    private final UserRepository userRepository;

    public UserServiceImpl(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public RegisterUserResponse registerUser(RegisterUserRequest registerUserRequest) {
        User user = new User();
        user.setUsername(registerUserRequest.getUsername());
        user.setPassword(registerUserRequest.getPassword());
        userRepository.save(user);
        RegisterUserResponse response = new RegisterUserResponse();
        response.setUserId(user.getId());
        response.setUsername(user.getUsername());
        response.setMessage("User successfully registered");
        return response;
    }

    @Override
    public LoginResponse login(LoginRequest loginRequest) {
        User user = findUserById(loginRequest.getUsername());
        if (!user.getPassword().equals(loginRequest.getPassword())) {
            throw new IllegalArgumentException("Invalid Credentials");
        }
        LoginResponse loginResponse = new LoginResponse();
        loginResponse.setMessage("User logged in successfully");
        return loginResponse;
    }

    private User findUserById(String username) {
        User user = userRepository.findByUsername(username);
        if (user == null) throw new IllegalArgumentException("Invalid Credentials");
        return user;
    }

    public static int Fibonacci(int number) {
        int num1 = 0;
        int num2 = 1;
        System.out.print("Fibonacci Series: " + num1 + " " + num2);

        for (int count = 1; count < number; count++) {
            int nextNumber = num1 + num2;
            System.out.print(" " + nextNumber);
            num1 = num2;
            num2 = nextNumber;
        }
        return num2;

    }

}
