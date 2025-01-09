package com.jorge.pkmntb.exceptions;

import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;

import java.util.Arrays;
import java.util.Objects;

@Slf4j
@ControllerAdvice
public class ExceptionHandlerService {

    @ResponseStatus(HttpStatus.FORBIDDEN)
    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ExceptionResponse> handleException(final AccessDeniedException e) {
        ExceptionResponse exceptionResponse = ExceptionResponse.forbidden(e.getMessage());
        log.error("[{}] AccessDeniedException: {}", exceptionResponse.getId(), e.getMessage());
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(exceptionResponse);
    }

    @ResponseStatus(HttpStatus.BAD_REQUEST)
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ExceptionResponse> handleException(final MethodArgumentNotValidException e) {
        final String message = Arrays.stream(Objects.requireNonNull(e.getDetailMessageArguments())).toList().get(1).toString();
        ExceptionResponse exceptionResponse = ExceptionResponse.badRequest(message);
        log.error("[{}] MethodArgumentNotValidException: {}", exceptionResponse.getId(), e.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exceptionResponse);
    }

    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ExceptionResponse> handleException(final DataIntegrityViolationException e) {
        ExceptionResponse exceptionResponse = ExceptionResponse.internalServerError(e.getMessage());
        log.error("[{}] DataIntegrityViolationException: {}", exceptionResponse.getId(), e.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(exceptionResponse);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ExceptionResponse> handleException(final IllegalArgumentException e) {
        ExceptionResponse exceptionResponse = ExceptionResponse.badRequest(e.getMessage());
        log.error("[{}] IllegalArgumentException: {}", exceptionResponse.getId(), e.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exceptionResponse);
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ExceptionResponse> handleException(final HttpRequestMethodNotSupportedException e) {
        ExceptionResponse exceptionResponse = ExceptionResponse.badRequest(e.getMessage());
        log.error("[{}] HttpRequestMethodNotSupportedException: {}", exceptionResponse.getId(), e.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exceptionResponse);
    }

    @ExceptionHandler(UnsupportedOperationException.class)
    public ResponseEntity<ExceptionResponse> handleException(final UnsupportedOperationException e) {
        ExceptionResponse exceptionResponse = ExceptionResponse.internalServerError(e.getMessage());
        log.error("[{}] UnsupportedOperationException: {}", exceptionResponse.getId(), e.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(exceptionResponse);
    }

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ExceptionResponse> handleException(final RuntimeException e) {
        ExceptionResponse exceptionResponse = ExceptionResponse.internalServerError(e.getMessage());
        log.error("[{}] RuntimeException ({}): {}", exceptionResponse.getId(), e.getClass(), e.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(exceptionResponse);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ExceptionResponse> handleException(final Exception e) {
        ExceptionResponse exceptionResponse = ExceptionResponse.internalServerError(e.getMessage());
        log.error("Exception ({}): {}", e.getClass(), e.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(exceptionResponse);
    }
}