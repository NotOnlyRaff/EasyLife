package com.easylife.controller;

import com.easylife.model.Subscription;
import com.easylife.service.SubscriptionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/subscriptions")
public class SubscriptionController {

    private final SubscriptionService subscriptionService;

    @Autowired
    public SubscriptionController(SubscriptionService subscriptionService) {
        this.subscriptionService = subscriptionService;
    }

    @PostMapping
    public ResponseEntity<Subscription> create(@RequestBody Subscription subscription) {
        return ResponseEntity.ok(subscriptionService.createSubscription(subscription));
    }

    @GetMapping
    public List<Subscription> getAll() {
        return subscriptionService.getAllSubscriptions();
    }

    @GetMapping("/{name}")
    public ResponseEntity<Subscription> getByName(@PathVariable String name) {
        return subscriptionService.getSubscriptionByName(name)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    @GetMapping("/email/{email}")
    public ResponseEntity<Subscription> getByEmail(@PathVariable String email) {
        return subscriptionService.getSubscriptionByEmail(email)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    @GetMapping("/type/{type}")
    public List<Subscription> getByType(@PathVariable String type) {
        return subscriptionService.getSubscriptionsByType(type);
    }
    @GetMapping("/active/{isActive}")
    public List<Subscription> getByIsActive(@PathVariable Boolean isActive) {
        return subscriptionService.getActiveSubscriptions(isActive);
    }
    @PutMapping("/{email}")
    public ResponseEntity<Subscription> updateByAccountEmail(@PathVariable String email, @RequestBody Subscription updated) {
        return subscriptionService.updateSubscriptionByAccountEmail(email, updated)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    @PutMapping("/{id}")
    public ResponseEntity<Subscription> updateByAccountId(@PathVariable Long id, @RequestBody Subscription updated) {
        return subscriptionService.updateSubscriptionById(id, updated)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    @DeleteMapping("/{email}")
    public ResponseEntity<Void> deleteByEmail(@PathVariable String email) {
        subscriptionService.deleteSubscriptionByEmail(email);
        return ResponseEntity.noContent().build();
    }
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteById(@PathVariable Long id) {
        subscriptionService.deleteSubscriptionById(id);
        return ResponseEntity.noContent().build();
    }
}
