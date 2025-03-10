package com.jorge.pkmntb.controller;

import com.jorge.pkmntb.model.User;
import com.jorge.pkmntb.service.UserService;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@AllArgsConstructor
@RequestMapping(path = "api/v2/user")
public class UserController {

    private UserService userService;

    @GetMapping
    public ResponseEntity<List<User>> getUsers() {
        return ResponseEntity.ok(userService.getUsers());
    }

    @PostMapping
    public ResponseEntity<String> registerUser(@RequestBody User user) {
        userService.addUser(user);
        return new ResponseEntity<>("User created successfully!", HttpStatus.CREATED);
    }
}
