package com.event.service;

import java.util.List;
import com.event.dao.EventDAO;
import com.event.dao.TicketDAO;
import com.event.model.Event;
import com.event.model.Ticket;
import com.event.model.User;

public class EventService {

    private EventDAO dao = new EventDAO();
    private TicketDAO ticketDao = new TicketDAO();

    // Add event with Duplicate Check
    public boolean createEvent(Event e) {
        e.setStatus("ACTIVE");
        if (e.getAvailableSeats() == 0) {
            e.setAvailableSeats(e.getCapacity());
        }
        return dao.createEvent(e);
    }

    // Get filtered active events
    public List<Event> getFilteredEvents(String query, String date, String location, String eligibility, String eventType) {
        return dao.getFilteredEvents(query, date, location, eligibility, eventType);
    }

    // Get all active events
    public List<Event> getAllEvents() {
        return dao.getAllEvents();
    }

    // Get single event by ID
    public Event getEventById(int eventId) {
        return dao.getEventById(eventId);
    }

    // Check if user is registered for an event
    public boolean isRegistered(int userId, int eventId) {
        return dao.isRegistered(userId, eventId);
    }

    // CORE ELIGIBILITY LOGIC
    public boolean isEligible(User user, Event event) {

        if (event == null) return false;

        String eligibility = event.getEligibility();

        // OPEN events: anyone can register
        if ("OPEN".equals(eligibility)) return true;

        // Must be logged in for restricted events
        if (user == null) return false;

        // COLLEGE_ONLY: only COLLEGE users
        if ("COLLEGE_ONLY".equals(eligibility)) {
            return "COLLEGE".equals(user.getUserType());
        }

        // COMPANY_ONLY: only COMPANY users
        if ("COMPANY_ONLY".equals(eligibility)) {
            return "COMPANY".equals(user.getUserType());
        }

        return false;
    }

    // Register user for event (with Capacity, Waitlist, Payments)
    public String register(User user, int eventId) {

        Event event = dao.getEventById(eventId);
        if (event == null) return "Event not found";

        if (!isEligible(user, event)) return "Not eligible for this event";
        if (dao.isRegistered(user.getId(), eventId)) return "Already registered";
        if (dao.isWaitlisted(user.getId(), eventId)) return "Already on Waitlist";

        // Handle Payment simulation
        if ("PAID".equals(event.getEventType()) && event.getPrice() > 0) {
            dao.recordPayment(user.getId(), eventId, event.getPrice(), "SUCCESS");
        }

        // Handle Capacity & Waitlist
        if (event.getAvailableSeats() <= 0) {
            boolean waitlistSuccess = dao.joinWaitlist(user.getId(), eventId);
            return waitlistSuccess ? "JOINED_WAITLIST" : "Failed to join waitlist";
        }

        // Normal Registration
        boolean success = dao.registerEvent(user.getId(), eventId);
        if (success) {
            dao.decrementSeats(eventId);
            return "SUCCESS";
        }
        
        return "Registration failed";
    }

    // Get events user registered for
    public List<Event> getRegisteredEvents(int userId) {
        return dao.getRegisteredEvents(userId);
    }

    // Report event (with duplicate check)
    public String reportEvent(int eventId, int userId) {
        if (dao.hasReported(userId, eventId)) {
            return "Already reported";
        }
        dao.reportEvent(eventId, userId);
        return "SUCCESS";
    }

    // Get events for specific organization
    public List<Event> getEventsByOrganization(int orgId) {
        return dao.getEventsByOrganization(orgId);
    }

    public boolean isWaitlisted(int userId, int eventId) {
        return dao.isWaitlisted(userId, eventId);
    }

    // Cancel Registration and pop waitlist natively via DAO
    public void cancelRegistration(int userId, int eventId) {
        // EventDAO handles the entire Atomic constraints loop natively (dropping team boundaries, increasing seats, popping waitlist, etc)
        dao.cancelRegistration(userId, eventId);
    }

    public void toggleEventStatus(int eventId) {
        dao.toggleEventStatus(eventId);
    }

    public double getEventRevenue(int eventId) {
        return dao.getEventRevenue(eventId);
    }

    // Payment Verification Delegation
    public java.util.List<java.util.Map<String, String>> getPendingPayments(int orgId) {
        return dao.getPendingPayments(orgId);
    }

    public void approvePayment(int paymentId) {
        dao.approvePayment(paymentId);
    }

    public void rejectPayment(int paymentId) {
        int[] details = dao.rejectPaymentAndGetDetails(paymentId);
        if (details != null) {
            cancelRegistration(details[0], details[1]);
        }
    }

    // Ticketing Engine Delegation
    public List<Ticket> getTicketsByUser(int userId) {
        return ticketDao.getTicketsByUser(userId);
    }

    public List<Ticket> getTicketsByEvent(int eventId) {
        return ticketDao.getTicketsByEvent(eventId);
    }

    public boolean markTicketUsed(String ticketId) {
        return ticketDao.markTicketUsed(ticketId);
    }
}