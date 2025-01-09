package com.jorge.pkmntb.service.imp;

import com.jorge.pkmntb.model.User;
import com.jorge.pkmntb.repository.UserRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

import java.util.Optional;

public class UserDetailsServiceImp implements UserDetailsService {

    private UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {

        Optional<User> userOptional = userRepository.findByUsername(username);
        if(userOptional.isEmpty()) {
            System.out.println("User not found");
            throw new UsernameNotFoundException("User not found");
        }

        return null;
    }
}
