# Backend Integration Examples

This document provides example implementations for various backend frameworks to receive OTP data from the OTP Listener app.

## Node.js/Express

### Basic Implementation

```javascript
const express = require('express');
const app = express();

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// OTP Endpoint
app.post('/otp', (req, res) => {
  const { sender, message, otp, timestamp } = req.body;

  // Validate required fields
  if (!sender || !message || !otp || !timestamp) {
    return res.status(400).json({
      status: 'error',
      message: 'Missing required fields'
    });
  }

  console.log('OTP Received:', {
    sender,
    message,
    otp,
    timestamp,
    receivedAt: new Date().toISOString()
  });

  // Process OTP (store in database, validate, etc.)
  // Example: validateOTP(sender, otp);

  res.json({
    status: 'success',
    message: 'OTP received and processed',
    data: { sender, otp, timestamp }
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    status: 'error',
    message: 'Internal server error'
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`OTP Listener server running on port ${PORT}`);
});
```

### With Database (MongoDB)

```javascript
const express = require('express');
const mongoose = require('mongoose');
const app = express();

app.use(express.json());

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

// Schema
const otpSchema = new mongoose.Schema({
  sender: String,
  message: String,
  otp: String,
  timestamp: Date,
  receivedAt: { type: Date, default: Date.now },
  status: { type: String, enum: ['pending', 'verified', 'expired'], default: 'pending' },
  expiresAt: { type: Date, default: () => new Date(+new Date() + 10*60000) } // 10 min
});

const OTP = mongoose.model('OTP', otpSchema);

// Endpoint
app.post('/otp', async (req, res) => {
  try {
    const { sender, message, otp, timestamp } = req.body;

    // Validate
    if (!sender || !message || !otp || !timestamp) {
      return res.status(400).json({
        status: 'error',
        message: 'Missing required fields'
      });
    }

    // Save to database
    const otpRecord = new OTP({
      sender,
      message,
      otp,
      timestamp: new Date(timestamp),
      status: 'pending'
    });

    await otpRecord.save();

    res.json({
      status: 'success',
      message: 'OTP received and stored',
      data: { _id: otpRecord._id, otp }
    });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to process OTP'
    });
  }
});

// Verify OTP endpoint
app.post('/otp/verify', async (req, res) => {
  try {
    const { sender, otp } = req.body;

    const record = await OTP.findOne({
      sender,
      otp,
      status: 'pending',
      expiresAt: { $gt: new Date() }
    });

    if (!record) {
      return res.status(400).json({
        status: 'error',
        message: 'Invalid or expired OTP'
      });
    }

    record.status = 'verified';
    await record.save();

    res.json({
      status: 'success',
      message: 'OTP verified'
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Verification failed'
    });
  }
});

app.listen(3000, () => {
  console.log('OTP server running on port 3000');
});
```

## Python/Flask

### Basic Implementation

```python
from flask import Flask, request, jsonify
from datetime import datetime
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

@app.route('/otp', methods=['POST'])
def receive_otp():
    try:
        data = request.get_json()

        # Validate required fields
        required_fields = ['sender', 'message', 'otp', 'timestamp']
        if not all(field in data for field in required_fields):
            return jsonify({
                'status': 'error',
                'message': 'Missing required fields'
            }), 400

        sender = data['sender']
        message = data['message']
        otp = data['otp']
        timestamp = data['timestamp']

        logging.info(f'OTP Received from {sender}: {otp}')

        # Process OTP
        # Example: verify_otp(sender, otp)

        return jsonify({
            'status': 'success',
            'message': 'OTP received and processed',
            'data': {
                'sender': sender,
                'otp': otp,
                'timestamp': timestamp
            }
        }), 200

    except Exception as e:
        logging.error(f'Error: {str(e)}')
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.errorhandler(404)
def not_found(error):
    return jsonify({
        'status': 'error',
        'message': 'Endpoint not found'
    }), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        'status': 'error',
        'message': 'Internal server error'
    }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000, debug=True)
```

### With PostgreSQL/SQLAlchemy

```python
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, timedelta
import os

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv(
    'DATABASE_URL',
    'postgresql://user:password@localhost/otp_db'
)
db = SQLAlchemy(app)

# OTP Model
class OTPRecord(db.Model):
    __tablename__ = 'otp_records'
    
    id = db.Column(db.Integer, primary_key=True)
    sender = db.Column(db.String(20), nullable=False)
    message = db.Column(db.Text, nullable=False)
    otp = db.Column(db.String(10), nullable=False)
    timestamp = db.Column(db.DateTime, nullable=False)
    received_at = db.Column(db.DateTime, default=datetime.utcnow)
    status = db.Column(db.String(20), default='pending')
    expires_at = db.Column(db.DateTime)

    def to_dict(self):
        return {
            'id': self.id,
            'sender': self.sender,
            'otp': self.otp,
            'timestamp': self.timestamp.isoformat(),
            'status': self.status
        }

@app.route('/otp', methods=['POST'])
def receive_otp():
    try:
        data = request.get_json()

        # Validate
        required_fields = ['sender', 'message', 'otp', 'timestamp']
        if not all(field in data for field in required_fields):
            return jsonify({'status': 'error', 'message': 'Missing fields'}), 400

        # Create record
        otp_record = OTPRecord(
            sender=data['sender'],
            message=data['message'],
            otp=data['otp'],
            timestamp=datetime.fromisoformat(data['timestamp'].replace('Z', '+00:00')),
            expires_at=datetime.utcnow() + timedelta(minutes=10)
        )

        db.session.add(otp_record)
        db.session.commit()

        return jsonify({
            'status': 'success',
            'message': 'OTP received',
            'data': otp_record.to_dict()
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/otp/verify', methods=['POST'])
def verify_otp():
    try:
        data = request.get_json()
        sender = data.get('sender')
        otp = data.get('otp')

        record = OTPRecord.query.filter(
            OTPRecord.sender == sender,
            OTPRecord.otp == otp,
            OTPRecord.status == 'pending',
            OTPRecord.expires_at > datetime.utcnow()
        ).first()

        if not record:
            return jsonify({'status': 'error', 'message': 'Invalid OTP'}), 400

        record.status = 'verified'
        db.session.commit()

        return jsonify({'status': 'success', 'message': 'OTP verified'}), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'status': 'error', 'message': str(e)}), 500

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=3000)
```

## Java/Spring Boot

### Basic Implementation

```java
package com.example.otplistener.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.example.otplistener.model.OTPRequest;
import com.example.otplistener.service.OTPService;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class OTPController {

    @Autowired
    private OTPService otpService;

    @PostMapping("/otp")
    public ResponseEntity<?> receiveOTP(@RequestBody OTPRequest request) {
        try {
            // Validate input
            if (request.getSender() == null || request.getOtp() == null ||
                request.getMessage() == null || request.getTimestamp() == null) {
                return ResponseEntity.badRequest().body(
                    createResponse("error", "Missing required fields")
                );
            }

            // Process OTP
            otpService.processOTP(request);

            return ResponseEntity.ok(
                createResponse("success", "OTP received and processed")
            );

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                createResponse("error", "Failed to process OTP")
            );
        }
    }

    @PostMapping("/otp/verify")
    public ResponseEntity<?> verifyOTP(
            @RequestParam String sender,
            @RequestParam String otp) {
        try {
            boolean isValid = otpService.verifyOTP(sender, otp);

            if (!isValid) {
                return ResponseEntity.badRequest().body(
                    createResponse("error", "Invalid or expired OTP")
                );
            }

            return ResponseEntity.ok(
                createResponse("success", "OTP verified")
            );

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                createResponse("error", "Verification failed")
            );
        }
    }

    private Map<String, Object> createResponse(String status, String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("status", status);
        response.put("message", message);
        return response;
    }
}
```

### OTP Service

```java
package com.example.otplistener.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.example.otplistener.model.OTPRecord;
import com.example.otplistener.model.OTPRequest;
import com.example.otplistener.repository.OTPRepository;
import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class OTPService {

    @Autowired
    private OTPRepository otpRepository;

    public void processOTP(OTPRequest request) {
        OTPRecord record = new OTPRecord();
        record.setSender(request.getSender());
        record.setMessage(request.getMessage());
        record.setOtp(request.getOtp());
        record.setTimestamp(request.getTimestamp());
        record.setReceivedAt(LocalDateTime.now());
        record.setStatus("pending");
        record.setExpiresAt(LocalDateTime.now().plusMinutes(10));

        otpRepository.save(record);
    }

    public boolean verifyOTP(String sender, String otp) {
        Optional<OTPRecord> record = otpRepository.findBySenderAndOtpAndStatus(
            sender, otp, "pending"
        );

        if (!record.isPresent()) {
            return false;
        }

        OTPRecord otpRecord = record.get();
        if (otpRecord.getExpiresAt().isBefore(LocalDateTime.now())) {
            return false;
        }

        otpRecord.setStatus("verified");
        otpRepository.save(otpRecord);
        return true;
    }
}
```

## .NET/C# (ASP.NET Core)

### Basic Implementation

```csharp
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;
using OTPListener.Models;
using OTPListener.Services;

namespace OTPListener.Controllers
{
    [ApiController]
    [Route("api")]
    public class OTPController : ControllerBase
    {
        private readonly IOTPService _otpService;
        private readonly ILogger<OTPController> _logger;

        public OTPController(IOTPService otpService, ILogger<OTPController> logger)
        {
            _otpService = otpService;
            _logger = logger;
        }

        [HttpPost("otp")]
        public async Task<IActionResult> ReceiveOTP([FromBody] OTPRequest request)
        {
            try
            {
                // Validate
                if (string.IsNullOrEmpty(request?.Sender) ||
                    string.IsNullOrEmpty(request?.Otp) ||
                    string.IsNullOrEmpty(request?.Message) ||
                    request?.Timestamp == null)
                {
                    return BadRequest(new
                    {
                        status = "error",
                        message = "Missing required fields"
                    });
                }

                _logger.LogInformation($"OTP received from {request.Sender}: {request.Otp}");

                // Process OTP
                await _otpService.ProcessOTPAsync(request);

                return Ok(new
                {
                    status = "success",
                    message = "OTP received and processed",
                    data = request
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing OTP");
                return StatusCode(500, new
                {
                    status = "error",
                    message = "Failed to process OTP"
                });
            }
        }

        [HttpPost("otp/verify")]
        public async Task<IActionResult> VerifyOTP(
            [FromQuery] string sender,
            [FromQuery] string otp)
        {
            try
            {
                bool isValid = await _otpService.VerifyOTPAsync(sender, otp);

                if (!isValid)
                {
                    return BadRequest(new
                    {
                        status = "error",
                        message = "Invalid or expired OTP"
                    });
                }

                return Ok(new
                {
                    status = "success",
                    message = "OTP verified"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error verifying OTP");
                return StatusCode(500, new
                {
                    status = "error",
                    message = "Verification failed"
                });
            }
        }
    }
}
```

## Testing with cURL

### Send OTP

```bash
curl -X POST http://localhost:3000/otp \
  -H "Content-Type: application/json" \
  -d '{
    "sender": "+1234567890",
    "message": "Your verification code is 123456",
    "otp": "123456",
    "timestamp": "2026-05-11T10:30:00.000Z"
  }'
```

### Verify OTP

```bash
curl -X POST "http://localhost:3000/otp/verify?sender=%2B1234567890&otp=123456"
```

## Testing with Postman

1. **Create new POST request**
   - URL: `http://localhost:3000/otp`
   - Body (JSON):
     ```json
     {
       "sender": "+1234567890",
       "message": "Your verification code is 123456",
       "otp": "123456",
       "timestamp": "2026-05-11T10:30:00.000Z"
     }
     ```

2. **Test verification**
   - URL: `http://localhost:3000/otp/verify?sender=%2B1234567890&otp=123456`

## Database Schema

### Table: otp_records

```sql
CREATE TABLE otp_records (
    id SERIAL PRIMARY KEY,
    sender VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    otp VARCHAR(10) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    received_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending',
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sender (sender),
    INDEX idx_otp (otp),
    INDEX idx_status (status)
);
```

## Error Handling

All backends should return:

```json
{
  "status": "error|success",
  "message": "Descriptive message",
  "data": { /* optional response data */ }
}
```

## Security Considerations

1. **Validate all input** before processing
2. **Implement rate limiting** to prevent abuse
3. **Log all requests** for audit trail
4. **Use HTTPS** in production
5. **Implement CORS** appropriately
6. **Add authentication** if needed
7. **Expire OTPs** after timeout
8. **Sanitize** error messages

## Performance Tips

1. Use indexes on `sender`, `otp`, `status` columns
2. Implement caching for frequently accessed data
3. Clean up expired OTPs periodically
4. Monitor request latency
5. Implement connection pooling

---

For more integration details, refer to the main `README_PRODUCTION.md`
