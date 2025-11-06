package com.cstar.schedulease.common.enums;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

public enum AppointmentStatus {
    CONFIRMED("CONFIRMED", "Confirmed"),
    CANCELLED("CANCELLED", "Cancelled"),
    COMPLETED("COMPLETED", "Completed"),
    NO_SHOW("NO_SHOW", "No Show");

    private final String code;
    private final String displayName;

    AppointmentStatus(String code, String displayName) {
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
    public static AppointmentStatus fromCode(String code) {
        if (code == null) {
            return null;
        }
        for (AppointmentStatus status : AppointmentStatus.values()) {
            if (status.code.equalsIgnoreCase(code)) {
                return status;
            }
        }
        throw new IllegalArgumentException("Invalid appointment status code: " + code + 
            ". Valid values are: CONFIRMED, CANCELLED, COMPLETED, NO_SHOW");
    }

    @Override
    public String toString() {
        return code;
    }
}

