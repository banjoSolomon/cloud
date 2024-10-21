package solo.controllers;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

import static solo.service.UserServiceImpl.generateFibonacci;

@RestController
public class FibonacciController {
    @GetMapping("/fibonacci/{number}")
    public List<Long> getFibonacci(@PathVariable int number) {
        return generateFibonacci(number);
    }
    }