package solo.service;


import org.springframework.stereotype.Service;

import solo.dto.RegisterUserRequest;
import solo.models.User;
import solo.repository.UserRepository;

import solo.response.RegisterUserResponse;

import java.util.ArrayList;
import java.util.List;

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


    public static List<Integer> generateFibonacci(int number) {
        List<Integer> fibonacciSeries = new ArrayList<>();
        int num1 = 0;
        int num2 = 1;
        fibonacciSeries.add(num1);
        fibonacciSeries.add(num2);

        for (int count = 2; count < number; count++) {
            int nextNumber = num1 + num2;
            fibonacciSeries.add(nextNumber);
            num1 = num2;
            num2 = nextNumber;
        }
        return fibonacciSeries;
    }

}
