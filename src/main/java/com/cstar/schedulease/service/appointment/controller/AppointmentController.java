package com.cstar.schedulease.service.appointment.controller;

import com.cstar.schedulease.common.enums.AppointmentStatus;
import com.cstar.schedulease.service.appointment.dto.AppointmentDTO;
import com.cstar.schedulease.service.appointment.service.AppointmentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/appointments")
@RequiredArgsConstructor
@Validated
public class AppointmentController {

    private final AppointmentService appointmentService;

    @PostMapping
    public ResponseEntity<AppointmentDTO> createAppointment(
            @Validated(AppointmentDTO.Create.class) @RequestBody AppointmentDTO appointmentDTO) {
        AppointmentDTO created = appointmentService.createAppointment(appointmentDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<AppointmentDTO> updateAppointmentStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> request) {
        
        String statusStr = request.get("status");
        if (statusStr == null) {
            return ResponseEntity.badRequest().build();
        }
        
        AppointmentStatus status = AppointmentStatus.fromValue(statusStr);
        String cancellationReason = request.get("cancellationReason");
        
        AppointmentDTO updated = appointmentService.updateAppointmentStatus(id, status, cancellationReason);
        return ResponseEntity.ok(updated);
    }

    @GetMapping("/{id}")
    public ResponseEntity<AppointmentDTO> getAppointmentById(@PathVariable Long id) {
        AppointmentDTO appointment = appointmentService.getAppointmentById(id);
        return ResponseEntity.ok(appointment);
    }

    @GetMapping
    public ResponseEntity<List<AppointmentDTO>> getAllAppointments(
            @RequestParam(required = false) Long clientId,
            @RequestParam(required = false) Long providerId,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Long startTime,
            @RequestParam(required = false) Long endTime) {
        
        if (clientId != null) {
            return ResponseEntity.ok(appointmentService.getAppointmentsByClientId(clientId));
        }
        
        if (providerId != null) {
            return ResponseEntity.ok(appointmentService.getAppointmentsByProviderId(providerId));
        }
        
        if (status != null) {
            AppointmentStatus appointmentStatus = AppointmentStatus.fromValue(status);
            return ResponseEntity.ok(appointmentService.getAppointmentsByStatus(appointmentStatus));
        }
        
        if (startTime != null && endTime != null) {
            return ResponseEntity.ok(appointmentService.getAppointmentsByTimeRange(startTime, endTime));
        }
        
        return ResponseEntity.ok(appointmentService.getAllAppointments());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAppointment(@PathVariable Long id) {
        appointmentService.deleteAppointment(id);
        return ResponseEntity.noContent().build();
    }
}

