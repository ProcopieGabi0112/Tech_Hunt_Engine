package com.techhunter.tech_hunter_engine_api.exception.postgres;


import com.techhunter.tech_hunter_engine_api.dto.postgres.error.ApiError;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.time.Instant;
import java.util.List;
import java.util.stream.Collectors;

@ControllerAdvice
public class GlobalExceptionHandler extends ResponseEntityExceptionHandler {

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<ApiError> handleResponseStatusException(ResponseStatusException ex, WebRequest request) {
        int statusValue = ex.getStatusCode().value();

        // încearcă să obții reason phrase din HttpStatus; dacă nu există, folosește toString() al HttpStatusCode
        String reasonPhrase = HttpStatus.resolve(statusValue) != null
                ? HttpStatus.resolve(statusValue).getReasonPhrase()
                : ex.getStatusCode().toString();

        ApiError error = ApiError.builder()
                .timestamp(Instant.now())
                .status(statusValue)
                .error(reasonPhrase)
                .message(ex.getReason())
                .path(request.getDescription(false).replace("uri=", ""))
                .build();
        return ResponseEntity.status(ex.getStatusCode()).body(error);
    }

    // Observă: semnătura folosește HttpStatusCode (Spring 6)
    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(
            MethodArgumentNotValidException ex, HttpHeaders headers, HttpStatusCode status, WebRequest request) {

        List<String> details = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .map(fe -> fe.getField() + ": " + fe.getDefaultMessage())
                .collect(Collectors.toList());

        // obține reason phrase din status (dacă se poate)
        String reasonPhrase = HttpStatus.resolve(status.value()) != null
                ? HttpStatus.resolve(status.value()).getReasonPhrase()
                : status.toString();

        ApiError error = ApiError.builder()
                .timestamp(Instant.now())
                .status(status.value())
                .error(reasonPhrase)
                .message("Validation failed")
                .path(request.getDescription(false).replace("uri=", ""))
                .details(details)
                .build();

        return ResponseEntity.status(status).headers(headers).body(error);
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ApiError> handleAccessDenied(AccessDeniedException ex, WebRequest request) {
        ApiError error = ApiError.builder()
                .timestamp(Instant.now())
                .status(HttpStatus.FORBIDDEN.value())
                .error(HttpStatus.FORBIDDEN.getReasonPhrase())
                .message("Access denied")
                .path(request.getDescription(false).replace("uri=", ""))
                .details(List.of(ex.getMessage()))
                .build();
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(error);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiError> handleAll(Exception ex, WebRequest request) {
        ApiError error = ApiError.builder()
                .timestamp(Instant.now())
                .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                .error(HttpStatus.INTERNAL_SERVER_ERROR.getReasonPhrase())
                .message(ex.getMessage())
                .path(request.getDescription(false).replace("uri=", ""))
                .build();
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}