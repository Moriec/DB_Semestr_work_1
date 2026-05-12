package com.vinogradov.consumerbd;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Task {
    private Long id;
    private String payload;
    private int attempts;
    private int priority;
    private Timestamp createdAt;
}
