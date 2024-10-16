package solo.controllers;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import solo.service.UserServiceImpl;

import java.util.List;

@RestController
public class FibonacciController {
    @GetMapping("/fibonacci/{number}")
    public List<Integer> getFibonacci(@PathVariable int number) {
        return UserServiceImpl.generateFibonacci(number);
    }
}