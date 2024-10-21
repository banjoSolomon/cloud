package solo.service;


import org.springframework.stereotype.Service;

import solo.dto.RegisterUserRequest;
import solo.models.User;
import solo.repository.UserRepository;

import solo.response.RegisterUserResponse;

import java.util.ArrayList;
import java.util.List;

@Service
public class UserServiceImpl implements UserService {
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


    public static List<Long> generateFibonacci(int count) {
        List<Long> fibonacciSeries = new ArrayList<>();
        long num1 = 0;
        long num2 = 1;

        // Generate a large number of Fibonacci numbers
        for (int i = 0; i < count; i++) {
            fibonacciSeries.add(num1);
            long nextNumber = num1 + num2;
            num1 = num2;
            num2 = nextNumber;

            // Print every 1000th Fibonacci number for visibility
            if (fibonacciSeries.size() % 1000 == 0) {
                System.out.println("Generated " + fibonacciSeries.size() + " Fibonacci numbers. Last number: " + num1);
            }
        }

        // Add the last Fibonacci number multiple times to fill memory
        for (int i = 0; i < 9000000; i++) { // Increasing the number of iterations
            fibonacciSeries.add(num1); // Adding the last Fibonacci number repeatedly
        }

        return fibonacciSeries;
    }
}