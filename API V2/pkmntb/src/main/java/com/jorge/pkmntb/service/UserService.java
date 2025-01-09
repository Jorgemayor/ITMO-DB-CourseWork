package com.jorge.pkmntb.service;

import com.jorge.pkmntb.exceptions.EmailAlreadyExistsException;
import com.jorge.pkmntb.model.Role;
import com.jorge.pkmntb.model.User;
import com.jorge.pkmntb.repository.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@AllArgsConstructor
public class UserService {

    private final PasswordEncoder passwordEncoder;
    private UserRepository userRepository;

    public Optional<User> findUserByEmail(String email) {
        return userRepository.findUserByEmail(email);
    }

    public void addUser(User user) {
        Optional<User> userOptional = userRepository.findUserByEmail(user.getEmail());
        if (userOptional.isPresent()) {
            throw new EmailAlreadyExistsException("Email already taken!");
        }

        if (user.getRole() == null || user.getRole().name().equals("INACTIVE")) {
            user.setRole(Role.USER);
        }

        String pass = passwordEncoder.encode(user.getPassword());
        user.setPassword(pass);
        userRepository.save(user);
    }}
