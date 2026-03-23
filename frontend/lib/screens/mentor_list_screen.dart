import 'package:flutter/material.dart';
import '../models/mentor.dart';
import 'mentor_profile_screen.dart';

class MentorListScreen extends StatelessWidget {
  const MentorListScreen({super.key});

  // Dummy Data - yeh static data hai (abhi ke liye)
  // Baad mein API se aayega
  List<Mentor> _getDummyMentors() {
    return [
      Mentor(
        id: '1',
        name: 'Dr. Rajesh Kumar',
        specialization: 'Machine Learning & AI',
        experience: '10 years',
        email: 'rajesh.kumar@cse.edu',
        bio: 'Expert in Machine Learning with 10+ years of experience. Published 50+ research papers.',
        rating: 4.8,
      ),
      Mentor(
        id: '2',
        name: 'Prof. Priya Sharma',
        specialization: 'Web Development',
        experience: '8 years',
        email: 'priya.sharma@cse.edu',
        bio: 'Full-stack developer specializing in React, Node.js, and modern web technologies.',
        rating: 4.9,
      ),
      Mentor(
        id: '3',
        name: 'Dr. Amit Patel',
        specialization: 'Data Science',
        experience: '12 years',
        email: 'amit.patel@cse.edu',
        bio: 'Data scientist with expertise in Python, SQL, and Big Data technologies.',
        rating: 4.7,
      ),
      Mentor(
        id: '4',
        name: 'Prof. Sneha Reddy',
        specialization: 'Mobile App Development',
        experience: '7 years',
        email: 'sneha.reddy@cse.edu',
        bio: 'Mobile app developer expert in Flutter, React Native, and native Android/iOS.',
        rating: 4.6,
      ),
      Mentor(
        id: '5',
        name: 'Dr. Vikram Singh',
        specialization: 'Cybersecurity',
        experience: '15 years',
        email: 'vikram.singh@cse.edu',
        bio: 'Cybersecurity expert with extensive knowledge in network security and ethical hacking.',
        rating: 4.9,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mentors = _getDummyMentors();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Available Mentors'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        // ListView.builder: List of items ko efficiently render karta hai
        padding: const EdgeInsets.all(16.0),
        itemCount: mentors.length, // Kitne items hain
        itemBuilder: (context, index) {
          // Har item ke liye yeh function call hota hai
          final mentor = mentors[index];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              // InkWell: Tap karne pe ripple effect deta hai
              onTap: () {
                // Mentor profile screen pe navigate karenge
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MentorProfileScreen(mentor: mentor),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture (Icon for now)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Mentor Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          Text(
                            mentor.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          
                          // Specialization
                          Text(
                            mentor.specialization,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          
                          // Experience & Rating
                          Row(
                            children: [
                              Icon(
                                Icons.work_outline,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                mentor.experience,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                mentor.rating.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Arrow Icon
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
