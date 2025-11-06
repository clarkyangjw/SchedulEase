package com.cstar.schedulease.common.enums;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

public enum Category {
    HAIRCUT("HAIRCUT", "Haircut"),
    MASSAGE("MASSAGE", "Massage");

    private final String code;
    private final String displayName;

    Category(String code, String displayName) {
        this.code = code;
        this.displayName = displayName;
    }

    @JsonValue
    public String getCode() {
        return code;
    }

    public String getDisplayName() {
        return displayName;
    }

    @JsonCreator
    public static Category fromCode(String code) {
        if (code == null) {
            return null;
        }
        for (Category category : Category.values()) {
            if (category.code.equalsIgnoreCase(code)) {
                return category;
            }
        }
        throw new IllegalArgumentException("Invalid category code: " + code + 
            ". Valid values are: HAIRCUT, MASSAGE");
    }

    @Override
    public String toString() {
        return code;
    }
}

