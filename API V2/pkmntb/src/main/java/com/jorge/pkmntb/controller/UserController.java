package com.jorge.pkmntb.controller;

import com.jorge.pkmntb.model.User;
import com.jorge.pkmntb.service.UserService;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@AllArgsConstructor
@RequestMapping(path = "api/user")
public class UserController {

    private UserService userService;

    @GetMapping
    public void getUsers() {

    }

    @PostMapping
    public ResponseEntity<String> registerUser(@RequestBody User user) {
        userService.addUser(user);
        return new ResponseEntity<>("User created successfully!", HttpStatus.CREATED);
    }
}
