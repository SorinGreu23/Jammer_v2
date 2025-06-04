package com.example.jammer.infrastructure.email;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import java.util.Map;

@Service
public class EmailService {
    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);
    
    private final JavaMailSender mailSender;
    private final TemplateEngine templateEngine;
    
    @Value("${spring.mail.from}")
    private String fromEmail;
    
    @Value("${app.frontend-url}")
    private String frontendUrl;

    @Value("${app.email.enabled:false}")
    private boolean emailEnabled;

    public EmailService(JavaMailSender mailSender, TemplateEngine templateEngine) {
        this.mailSender = mailSender;
        this.templateEngine = templateEngine;
    }

    public void sendBoardInvitation(String toEmail, String boardName, String invitationToken) {
        if (!emailEnabled) {
            logger.info("Email sending is disabled. Would have sent invitation to {} for board {}", toEmail, boardName);
            logger.info("Invitation link would be: {}/boards/join?token={}", frontendUrl, invitationToken);
            return;
        }

        try {
            Context context = new Context();
            context.setVariables(Map.of(
                "boardName", boardName,
                "invitationLink", frontendUrl + "/boards/join?token=" + invitationToken
            ));

            String emailContent = templateEngine.process("board-invitation", context);
            
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail);
            helper.setTo(toEmail);
            helper.setSubject("You've been invited to join " + boardName + " on Jammer");
            helper.setText(emailContent, true);
            
            mailSender.send(message);
            logger.info("Successfully sent invitation email to {} for board {}", toEmail, boardName);
        } catch (MessagingException e) {
            logger.error("Failed to send invitation email to {} for board {}: {}", toEmail, boardName, e.getMessage());
            // Don't throw an exception, just log the error
            // This allows the invitation to be created even if email sending fails
        }
    }
} 