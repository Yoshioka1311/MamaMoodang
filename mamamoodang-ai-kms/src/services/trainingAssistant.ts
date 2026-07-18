import type { KnowledgeTopic, TopicChatMessage } from '../types/knowledge';

function recentContext(messages: TopicChatMessage[]) {
  return messages
    .slice(-8)
    .map((message) => `${message.role === 'user' ? 'Admin' : 'AI'}: ${message.message}`)
    .join('\n');
}

function topicFocus(topic: KnowledgeTopic) {
  return `${topic.title} (${topic.categoryName})`;
}

function includesAny(value: string, keywords: string[]) {
  return keywords.some((keyword) => value.includes(keyword));
}

function shouldReplyThai(prompt: string, messages: TopicChatMessage[]) {
  const thaiText = /[\u0E00-\u0E7F]/;
  return thaiText.test(prompt) || messages.slice(-4).some((message) => thaiText.test(message.message));
}

export function generateTrainingResponse(topic: KnowledgeTopic, messages: TopicChatMessage[], prompt: string) {
  const lower = prompt.toLowerCase();
  const context = recentContext(messages);
  const focus = topicFocus(topic);
  const replyThai = shouldReplyThai(prompt, messages);

  if (includesAny(lower, ['faq', 'คำถาม', 'ถามตอบ'])) {
    if (replyThai) {
      return `## ร่าง FAQ สำหรับ ${focus}

**Q: Buddy ควรอธิบายอะไรก่อน?**
เริ่มจากคำอธิบายที่ปลอดภัย เข้าใจง่าย และไม่ทำให้ผู้ใช้รู้สึกผิดหรือกังวลเกินจำเป็น

**Q: Chatbot ควรหลีกเลี่ยงอะไร?**
หลีกเลี่ยงการวินิจฉัยโรค การรับประกันผลลัพธ์ และการแทนคำแนะนำเฉพาะบุคคลจากแพทย์หรือทีมดูแลเบาหวาน

**Q: ควรแปลงเป็นความรู้ของ chatbot อย่างไร?**
เก็บเป็นคำแนะนำสั้นๆ ขอบเขตความปลอดภัย สัญญาณที่ควรติดต่อบุคลากรทางการแพทย์ และตัวอย่างภาษาที่ Buddy ควรใช้`;
    }

    return `## FAQ draft for ${focus}

**Q: What should Buddy explain first?**
Buddy should start with the safest, simplest explanation and avoid making the user feel blamed.

**Q: What should the chatbot avoid?**
Avoid diagnosis, absolute promises, and replacing advice from the user's doctor or diabetes care team.

**Q: How should this become chatbot knowledge?**
Store the final answer as short guidance, safety boundaries, escalation signs, and Buddy-style wording.`;
  }

  if (includesAny(lower, ['simplify', 'patient', 'ง่าย', 'คนไข้', 'ผู้ป่วย', 'เข้าใจง่าย'])) {
    if (replyThai) {
      return `นี่คือเวอร์ชันที่เหมาะกับผู้ใช้ทั่วไปสำหรับ **${focus}**:

Buddy สามารถพูดแบบนุ่มนวลและชัดเจนได้ว่า:

"มาค่อยๆ ดูไปด้วยกันนะ ร่างกายของแต่ละคนตอบสนองไม่เหมือนกันในแต่ละวัน เราจะเลือกวิธีที่ปลอดภัยกว่า สังเกตอาการ และใช้ค่าที่บันทึกไว้หรือแผนจากทีมดูแลเป็นตัวช่วยตัดสินใจ"

ขอบเขตด้านความปลอดภัย: เนื้อหานี้ใช้เพื่อให้ความรู้และช่วยเตรียมคำถามสำหรับทีมดูแล ไม่ควรใช้แทนคำแนะนำทางการแพทย์เฉพาะบุคคล`;
    }

    return `Here is a patient-friendly version for **${focus}**:

Buddy can say this gently and clearly:

"Let us keep this simple. Your body may respond differently day by day, so we will choose the safer option, watch how you feel, and use your readings or care-team plan as the guide."

Medical safety boundary: this should support education only and should not replace personalized clinical advice.`;
  }

  if (includesAny(lower, ['reference', 'อ้างอิง', 'แหล่งข้อมูล', 'งานวิจัย'])) {
    if (replyThai) {
      return `## แผนตรวจแหล่งอ้างอิงสำหรับ ${focus}

- ใช้แนวทางจากองค์กรทางการแพทย์หรือสาธารณสุขที่เชื่อถือได้เป็นหลัก
- แยกข้อมูลที่ยืนยันแล้วออกจากโทนการพูดเฉพาะของ Buddy
- เพิ่ม note ด้านความปลอดภัยเมื่อหัวข้อเกี่ยวกับอาการ ยา ค่าน้ำตาล อากาศร้อน มลพิษ หรือภาวะอารมณ์
- ทำเครื่องหมายข้อมูลที่ยังไม่แน่ใจไว้ให้ medical reviewer ตรวจซ้ำก่อนนำเข้า chatbot`;
    }

    return `## Reference plan for ${focus}

- Use official clinical or public-health guidance where possible.
- Separate confirmed guidance from app-specific Buddy tone.
- Add a safety note when the topic involves symptoms, medication, glucose readings, heat, air quality, or emotional distress.
- Mark any uncertain claim for medical review before chatbot release.`;
  }

  if (includesAny(lower, ['buddy', 'บัดดี้', 'โทน', 'น้ำเสียง'])) {
    if (replyThai) {
      return `## ตัวอย่างคำตอบสไตล์ Buddy สำหรับ ${focus}

1. "เราอยู่ตรงนี้ด้วยกันนะ ค่อยๆ ทำทีละขั้นก็พอ"
2. "เรื่องนี้สำคัญ เราจะเลือกวิธีที่อ่อนโยน ปลอดภัย และดูจากสิ่งที่ร่างกายบอกเรา"
3. "ถ้ามีอาการที่น่ากังวลหรือไม่แน่ใจ ทีมดูแลของคุณคือแหล่งยืนยันที่เหมาะที่สุด"

กฎโทนเสียง: อบอุ่น สั้น ไม่ตัดสิน และระวังเรื่องคำแนะนำทางการแพทย์`;
    }

    return `## Buddy response candidates for ${focus}

1. "I am here with you. Let us take this one small step at a time."
2. "That sounds important. We can keep it gentle, safe, and check what your body tells us."
3. "If anything feels worrying or unusual, your care team is the best place to confirm what is right for you."

Tone rules: warm, short, non-judgmental, medically cautious.`;
  }

  if (includesAny(lower, ['summarize', 'summary', 'สรุป', 'ย่อ', 'สรุปความรู้'])) {
    if (replyThai) {
      return `## สรุปความรู้ระหว่างทำงานสำหรับ ${focus}

จากบทสนทนาล่าสุด:

${context || 'ยังไม่มีรายละเอียดเพิ่มเติมในหัวข้อนี้'}

โครงสร้างความรู้ที่แนะนำ:
- คำอธิบายหลัก
- สิ่งที่ Buddy ควรพูด
- ขอบเขตความปลอดภัย
- เมื่อไหร่ควรติดต่อบุคลากรทางการแพทย์
- keyword สำหรับช่วยค้นคืนข้อมูล`;
    }

    return `## Working summary for ${focus}

Based on this conversation so far:

${context || 'No detailed notes have been added yet.'}

Suggested knowledge structure:
- Core explanation
- What Buddy should say
- Safety boundaries
- When to contact a healthcare professional
- Keywords for retrieval`;
  }

  if (replyThai) {
    return `ฉันจะช่วยสร้างหัวข้อความรู้นี้: **${focus}**

นี่คือร่าง training ที่จัดให้อ่านและนำไปต่อยอดได้ง่ายขึ้นจากข้อความของคุณ:

${prompt}

ขั้นตอนถัดไปที่แนะนำ: ขอให้ฉัน **ขยายรายละเอียด**, **อธิบายให้คนไข้เข้าใจง่าย**, **ทำ FAQ**, **เขียนคำตอบสไตล์ Buddy**, **เพิ่มขอบเขตความปลอดภัย**, หรือ **แปลงเป็น knowledge สำหรับ chatbot** ได้เลย ทุกข้อความในบทสนทนานี้จะถูกบันทึกเป็นส่วนหนึ่งของฐานความรู้`;
  }

  return `I will help build this knowledge topic: **${focus}**.

Here is a stronger training draft based on your message:

${prompt}

Recommended next step: ask me to **expand**, **simplify for patients**, **create FAQs**, **write Buddy responses**, **add safety boundaries**, or **convert this into chatbot knowledge**. Every message in this conversation is already saved as part of the knowledge base.`;
}
