package com.cstar.schedulease.service.services.dto;

import com.cstar.schedulease.common.enums.Category;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ServiceDTO {
    
    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    private Long id;

    @NotBlank(message = "Service name is required", groups = Create.class)
    @Size(min = 1, max = 200, message = "Service name must be between 1 and 200 characters")
    private String name;

    @Size(max = 5000, message = "Description must not exceed 5000 characters")
    private String description;

    @NotNull(message = "Category is required", groups = Create.class)
    private Category category;

    @NotNull(message = "Duration is required", groups = Create.class)
    @Min(value = 1, message = "Duration must be at least 1 minute")
    @Max(value = 1440, message = "Duration must not exceed 1440 minutes (24 hours)")
    private Integer duration; // in minutes

    @DecimalMin(value = "0.00", message = "Price must be non-negative")
    @Digits(integer = 8, fraction = 2, message = "Price must have at most 8 integer digits and 2 decimal places")
    private BigDecimal price;

    private Boolean isActive;

    public interface Create {}
    public interface Update {}
}

